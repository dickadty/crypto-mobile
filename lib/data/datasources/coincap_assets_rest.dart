import 'dart:convert';
import 'package:crypto_mvp_getx/data/models/assets_info.dart';
import 'package:http/http.dart' as http;
import 'package:crypto_mvp_getx/core/coincap_env.dart';

class CoinCapAssetsRest {
  /// Ambil daftar aset (top-N). Bisa dipaging dengan offset.
  Future<List<AssetInfo>> fetchAssets({int limit = 200, int offset = 0}) async {
    var uri = Uri.parse('${CoinCapEnv.baseUrl}/assets').replace(
      queryParameters: {
        'limit': '$limit',
        if (offset > 0) 'offset': '$offset',
        if (CoinCapEnv.apiKey.isNotEmpty) 'apiKey': CoinCapEnv.apiKey,
      },
    );

    final headers = <String, String>{
      'accept': 'application/json',
      if (CoinCapEnv.apiKey.isNotEmpty)
        'Authorization': 'Bearer ${CoinCapEnv.apiKey}',
    };

    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode != 200) {
      throw Exception('Assets failed: ${resp.statusCode} ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);
    final List list = decoded is Map && decoded['data'] is List
        ? decoded['data'] as List
        : (decoded as List);

    return list
        .map((e) => AssetInfo.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Detail satu aset: market cap & 24h volume, dll. -> kembalikan AssetInfo
  Future<AssetInfo> fetchAssetDetail(String slug) async {
    var uri = Uri.parse('${CoinCapEnv.baseUrl}/assets/$slug');
    if (CoinCapEnv.apiKey.isNotEmpty) {
      uri = uri.replace(queryParameters: {'apiKey': CoinCapEnv.apiKey});
    }

    final headers = <String, String>{
      'accept': 'application/json',
      if (CoinCapEnv.apiKey.isNotEmpty)
        'Authorization': 'Bearer ${CoinCapEnv.apiKey}',
    };

    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode != 200) {
      throw Exception('Asset detail failed: ${resp.statusCode} ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);
    return AssetInfo.fromJson(decoded);
  }
}
