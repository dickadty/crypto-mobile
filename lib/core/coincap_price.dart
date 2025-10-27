import 'dart:convert';
import 'package:crypto_mvp_getx/core/coincap_env.dart';
import 'package:http/http.dart' as http;


class CoinCapPriceRest {
  Future<double?> priceBySymbol(String symbol) async {
    final qp = <String, String>{};
    if (CoinCapEnv.apiKey.isNotEmpty) {
      qp['apiKey'] = CoinCapEnv.apiKey; // beberapa setup menerima apiKey di query
    }
    final uri = Uri.parse('${CoinCapEnv.baseUrl}/price/bysymbol/$symbol')
        .replace(queryParameters: qp);

    final headers = <String, String>{
      'accept': '*/*',
      if (CoinCapEnv.apiKey.isNotEmpty)
        'Authorization': 'Bearer ${CoinCapEnv.apiKey}',
    };

    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode != 200) return null;

    final decoded = jsonDecode(resp.body);
    // bentuk umum: { "BTC": 68000.0 }
    if (decoded is Map<String, dynamic>) {
      final v = decoded[symbol];
      if (v is num) return v.toDouble();
      if (v != null) return double.tryParse(v.toString());
    }
    return null;
  }
}
