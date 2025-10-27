import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:crypto_mvp_getx/core/coincap_env.dart';

/// WS harga CoinCap
class CoinCapWsClient {
  WebSocketChannel? _ch;

  void connect({
    required List<String> assets,
    required void Function(Map<String, double>) onPrices,
    void Function(Object)? onError,
    void Function()? onDone,
  }) {
    close();

    final normalized = assets.map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty).toList();
    final assetsParam = normalized.isEmpty ? 'ALL' : normalized.join(',');

    final apiKey = CoinCapEnv.apiKey.trim();
    if (apiKey.isEmpty) {
      final err = ArgumentError('CoinCap API key kosong. Set COINCAP_API_KEY via --dart-define.');
      onError?.call(err);
      return;
    }

    final uri = Uri.parse(
      '${CoinCapEnv.wsUrl}/prices?apiKey=${Uri.encodeComponent(apiKey)}&assets=$assetsParam',
    );
    // ignore: avoid_print
    print('[WS] Connecting: $uri');

    _ch = WebSocketChannel.connect(uri);

    _ch!.stream.listen((raw) {
      final jsonStr = raw.toString();
      Map<String, dynamic> obj;
      try {
        obj = jsonDecode(jsonStr) as Map<String, dynamic>;
      } catch (_) {
        return;
      }
      final out = <String, double>{};
      obj.forEach((k, v) {
        final d = (v is num) ? v.toDouble() : double.tryParse(v.toString());
        if (d != null) out[k] = d;
      });
      if (out.isNotEmpty) onPrices(out);
    }, onError: (e) {
      onError?.call(e);
    }, onDone: () {
      onDone?.call();
    });
  }

  void close() {
    try { _ch?.sink.close(); } catch (_) {}
    _ch = null;
  }
}
