import 'dart:async';
import 'package:http/http.dart' as http;

typedef Extractor = List<dynamic> Function(dynamic);

List<dynamic> extractList(
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
  // Jika bukan list, kembalikan list kosong supaya aman
  return const [];
}

Future<http.Response> getWithTimeout(
  http.Client client,
  Uri uri, {
  Map<String, String>? headers,
  Duration timeout = const Duration(seconds: 12),
}) {
  return client.get(uri, headers: headers).timeout(timeout);
}
