import 'dart:async';
import 'dart:convert';
import 'package:crypto_mvp_getx/data/models/chandle.dart';
import 'package:http/http.dart' as http;
import '../../core/coincap_env.dart';

double _d(x) => x is num ? x.toDouble() : double.parse('$x');
int _i(x) => x is int ? x : int.parse('$x');

Future<http.Response> _getWithTimeout(
  http.Client client,
  Uri uri, {
  Map<String, String>? headers,
  Duration timeout = const Duration(seconds: 12),
}) {
  return client.get(uri, headers: headers).timeout(timeout);
}

List<dynamic> _extractList(
  dynamic decoded, {
  List<String> keys = const ['data'],
}) {
  if (decoded is List) return decoded;
  if (decoded is Map<String, dynamic>) {
    for (final k in keys) {
      final v = decoded[k];
      if (v is List) return v;
    }
  }
  return const [];
}

Duration _intervalToStep(String interval) {
  return {
        'm1': const Duration(minutes: 1),
        'm5': const Duration(minutes: 5),
        'm15': const Duration(minutes: 15),
        'm30': const Duration(minutes: 30),
        'h1': const Duration(hours: 1),
        'h2': const Duration(hours: 2),
        'h6': const Duration(hours: 6),
        'h12': const Duration(hours: 12),
        'd1': const Duration(days: 1),
      }[interval] ??
      const Duration(minutes: 5);
}

class CoinCapRestClient {
  final http.Client _client;
  CoinCapRestClient([http.Client? client]) : _client = client ?? http.Client();

  Map<String, String> _headers() => {
    'accept': 'application/json',
    if (CoinCapEnv.apiKey.isNotEmpty)
      'Authorization': 'Bearer ${CoinCapEnv.apiKey}',
  };

  Uri _uri(String path, [Map<String, String>? qp]) {
    final base = Uri.parse('${CoinCapEnv.baseUrl}$path');
    final q = <String, String>{};
    if (qp != null) q.addAll(qp);
    if (CoinCapEnv.apiKey.isNotEmpty)
      q.putIfAbsent('apiKey', () => CoinCapEnv.apiKey);
    return base.replace(queryParameters: q.isEmpty ? null : q);
  }

  String _candlesPath(String slug) => '/ta/$slug/candlesticks';

  /// Candles by explicit time window (OHLC)
  Future<List<Candle>> fetchCandlesByTime({
    required String slug,
    required String interval, // m1..d1
    required int startMs,
    required int endMs,
  }) async {
    final uri = _uri(_candlesPath(slug), {
      'interval': interval,
      'start': '$startMs',
      'end': '$endMs',
    });

    final resp = await _getWithTimeout(_client, uri, headers: _headers());
    if (resp.statusCode != 200) {
      throw Exception('Candles failed: ${resp.statusCode} ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);
    final rows = _extractList(
      decoded,
      keys: const ['data', 'candles', 'candlesticks', 'items', 'result'],
    );

    return rows
        .map<Candle>((e) {
          final m = e as Map<String, dynamic>;
          final timeMs = _i(m['time'] ?? m['t']);
          return Candle(
            time: DateTime.fromMillisecondsSinceEpoch(
              timeMs,
              isUtc: true,
            ).toLocal(),
            open: _d(m['open'] ?? m['o']),
            high: _d(m['high'] ?? m['h']),
            low: _d(m['low'] ?? m['l']),
            close: _d(m['close'] ?? m['c']),
            volume: m['volume'] == null ? null : _d(m['volume']),
          );
        })
        .toList(growable: false);
  }

  /// Candles last N (ringkas)
  Future<List<Candle>> fetchCandlesLastN({
    required String slug,
    String interval = 'm5',
    int count = 200,
  }) async {
    final step = _intervalToStep(interval);
    final now = DateTime.now().toUtc();
    final end = now.millisecondsSinceEpoch;
    final start = now.subtract(step * count).millisecondsSinceEpoch;

    return fetchCandlesByTime(
      slug: slug,
      interval: interval,
      startMs: start,
      endMs: end,
    );
  }

  /// NEW: Ambil candle history panjang (paged) berbulan-bulan
  Future<List<Candle>> fetchCandlesLookbackPaged({
    required String slug,
    String interval = 'm5',
    int lookbackDays = 180,
    int maxPointsPerCall = 1000,
  }) async {
    final step = _intervalToStep(interval);
    final perCall = step * maxPointsPerCall;

    final nowUtc = DateTime.now().toUtc();
    final endAll = nowUtc.millisecondsSinceEpoch;
    final startAll = nowUtc
        .subtract(Duration(days: lookbackDays))
        .millisecondsSinceEpoch;

    final out = <Candle>[];
    int windowEnd = endAll;

    while (true) {
      final windowStart = windowEnd - perCall.inMilliseconds;
      final start = windowStart < startAll ? startAll : windowStart;
      if (start >= windowEnd) break;

      final part = await fetchCandlesByTime(
        slug: slug,
        interval: interval,
        startMs: start,
        endMs: windowEnd,
      );

      // kita berjalan mundur — sisipkan di depan agar tetap ascending
      out.insertAll(0, part);

      if (start == startAll) break;
      windowEnd = start;
    }

    // de-duplicate & sort
    final seen = <int>{};
    final uniq = <Candle>[];
    for (final c in out) {
      final key = c.time.millisecondsSinceEpoch;
      if (seen.add(key)) uniq.add(c);
    }
    uniq.sort((a, b) => a.time.compareTo(b.time));
    return uniq;
  }

  void close() => _client.close();
}
