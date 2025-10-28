import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/coincap_env.dart';

class CoinCapWsClient {
  WebSocketChannel? _ch;
  int _retries = 0;
  Timer? _reconnectTimer;

  // throttle buffer
  final Map<String, double> _buffer = {};
  Timer? _flushTimer;

  void connect({
    required List<String> assets,
    required void Function(Map<String, double>) onPrices,
    void Function(Object)? onError,
    void Function()? onDone,
  }) {
    close();

    final normalized = assets
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();
    final assetsParam = normalized.isEmpty ? 'ALL' : normalized.join(',');

    final apiKey = CoinCapEnv.apiKey.trim();
    if (apiKey.isEmpty) {
      final err = ArgumentError(
        'CoinCap API key kosong. Set COINCAP_API_KEY via --dart-define.',
      );
      onError?.call(err);
      return;
    }

    final uri = Uri.parse(
      '${CoinCapEnv.wsUrl}/prices?apiKey=${Uri.encodeComponent(apiKey)}&assets=$assetsParam',
    );
    _ch = WebSocketChannel.connect(uri);

    _ch!.stream.listen(
      (raw) {
        final s = raw.toString();
        Map<String, dynamic> obj;
        try {
          obj = jsonDecode(s) as Map<String, dynamic>;
        } catch (_) {
          return;
        }
        obj.forEach((k, v) {
          final d = (v is num) ? v.toDouble() : double.tryParse(v.toString());
          if (d != null) _buffer[k] = d;
        });

        _flushTimer ??= Timer(const Duration(milliseconds: 200), () {
          if (_buffer.isNotEmpty) onPrices(Map<String, double>.from(_buffer));
          _buffer.clear();
          _flushTimer = null;
        });
      },
      onError: (e) {
        onError?.call(e);
        _scheduleReconnect(assets, onPrices, onError, onDone);
      },
      onDone: () {
        onDone?.call();
        _scheduleReconnect(assets, onPrices, onError, onDone);
      },
    );
  }

  void _scheduleReconnect(
    List<String> assets,
    void Function(Map<String, double>) onPrices,
    void Function(Object)? onError,
    void Function()? onDone,
  ) {
    if (_reconnectTimer != null) return;
    final delay = Duration(milliseconds: 500 * (1 << (_retries.clamp(0, 5))));
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      _retries++;
      connect(
        assets: assets,
        onPrices: onPrices,
        onError: onError,
        onDone: onDone,
      );
    });
  }

  void close() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _retries = 0;
    _flushTimer?.cancel();
    _flushTimer = null;
    try {
      _ch?.sink.close();
    } catch (_) {}
    _ch = null;
  }
}
