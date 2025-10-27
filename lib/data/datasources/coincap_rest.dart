import 'dart:convert';
import 'package:crypto_mvp_getx/data/models/chandle.dart';
import 'package:http/http.dart' as http;
import 'package:crypto_mvp_getx/core/coincap_env.dart';

double _d(x) => x is num ? x.toDouble() : double.parse(x.toString());
int _i(x) => x is int ? x : int.parse(x.toString());

class CoinCapRestClient {
  String _candlesUrl(String slug) => '${CoinCapEnv.baseUrl}/ta/$slug/candlesticks';

  Future<List<Candle>> fetchCandlesByTime({
    required String slug,
    required String interval, // m1..d1
    required int startMs,
    required int endMs,
  }) async {
    final qp = <String, String>{
      'interval': interval,
      'start': '$startMs',
      'end': '$endMs',
      if (CoinCapEnv.apiKey.isNotEmpty) 'apiKey': CoinCapEnv.apiKey,
    };

    final uri = Uri.parse(_candlesUrl(slug)).replace(queryParameters: qp);

    final headers = <String, String>{
      'accept': 'application/json',
      if (CoinCapEnv.apiKey.isNotEmpty)
        'Authorization': 'Bearer ${CoinCapEnv.apiKey}',
    };

    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode != 200) {
      throw Exception('Candles failed: ${resp.statusCode} ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);
    List<dynamic> rows = const [];
    if (decoded is List) {
      rows = decoded;
    } else if (decoded is Map<String, dynamic>) {
      final candidates = ['data', 'candles', 'candlesticks', 'items', 'result'];
      dynamic payload;
      for (final k in candidates) {
        if (decoded.containsKey(k)) { payload = decoded[k]; break; }
      }
      if (payload is List) {
        rows = payload;
      } else if (payload == null) {
        rows = const [];
      } else {
        throw FormatException('Unexpected response: ${resp.body}');
      }
    } else {
      throw FormatException('Unknown JSON root: ${resp.body}');
    }

    return rows.map((e) {
      final m = e as Map<String, dynamic>;
      final timeMs = _i(m['time'] ?? m['t']);
      return Candle(
        time: DateTime.fromMillisecondsSinceEpoch(timeMs, isUtc: true).toLocal(),
        open:  _d(m['open']  ?? m['o']),
        high:  _d(m['high']  ?? m['h']),
        low:   _d(m['low']   ?? m['l']),
        close: _d(m['close'] ?? m['c']),
        volume: m['volume'] == null ? null : _d(m['volume']),
      );
    }).toList(growable: false);
  }

  Future<List<Candle>> fetchCandlesLastN({
    required String slug,
    String interval = 'm5',
    int count = 200,
  }) async {
    final step = {
      'm1': const Duration(minutes: 1),
      'm5': const Duration(minutes: 5),
      'm15': const Duration(minutes: 15),
      'm30': const Duration(minutes: 30),
      'h1': const Duration(hours: 1),
      'h2': const Duration(hours: 2),
      'h6': const Duration(hours: 6),
      'h12': const Duration(hours: 12),
      'd1': const Duration(days: 1),
    }[interval] ?? const Duration(minutes: 5);

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
}
