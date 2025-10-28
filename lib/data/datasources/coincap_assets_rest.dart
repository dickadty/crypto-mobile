import 'dart:convert';
import 'package:crypto_mvp_getx/data/models/assets_info.dart';
import 'package:http/http.dart' as http;
import '../../core/coincap_env.dart';
import '_rest_base.dart';

class CoinCapAssetsRest {
  final http.Client _client;
  CoinCapAssetsRest([http.Client? client]) : _client = client ?? http.Client();

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

  Future<List<AssetInfo>> fetchAssets({int limit = 200, int offset = 0}) async {
    final uri = _uri('/assets', {
      'limit': '$limit',
      if (offset > 0) 'offset': '$offset',
    });

    final resp = await getWithTimeout(_client, uri, headers: _headers());
    if (resp.statusCode != 200) {
      throw Exception('Assets failed: ${resp.statusCode} ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);
    final list = extractList(decoded, keys: const ['data']);
    return list
        .map((e) => AssetInfo.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<AssetInfo> fetchAssetDetail(String slug) async {
    final uri = _uri('/assets/$slug');
    final resp = await getWithTimeout(_client, uri, headers: _headers());
    if (resp.statusCode != 200) {
      throw Exception('Asset detail failed: ${resp.statusCode} ${resp.body}');
    }
    final decoded = jsonDecode(resp.body);
    return AssetInfo.fromJson(decoded);
  }

  void close() => _client.close();
}
