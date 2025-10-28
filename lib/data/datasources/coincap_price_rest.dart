import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/coincap_env.dart';
import '_rest_base.dart';

class CoinCapPriceRest {
  final http.Client _client;
  CoinCapPriceRest([http.Client? client]) : _client = client ?? http.Client();

  Map<String, String> _headers() => {
    'accept': 'application/json',
    if (CoinCapEnv.apiKey.isNotEmpty)
      'Authorization': 'Bearer ${CoinCapEnv.apiKey}',
  };

  Future<List<double?>> pricesBySymbols(List<String> symbols) async {
    if (symbols.isEmpty) return const [];
    final csv = symbols.join(',');

    var uri = Uri.parse('${CoinCapEnv.baseUrl}/price/bysymbol/$csv');
    final qp = <String, String>{};
    if (CoinCapEnv.apiKey.isNotEmpty) qp['apiKey'] = CoinCapEnv.apiKey;
    uri = uri.replace(queryParameters: qp.isEmpty ? null : qp);

    final resp = await getWithTimeout(_client, uri, headers: _headers());
    if (resp.statusCode != 200) {
      throw Exception(
        'Price by symbol failed: ${resp.statusCode} ${resp.body}',
      );
    }

    final decoded = jsonDecode(resp.body);
    final List<dynamic> arr = (decoded is Map && decoded['data'] is List)
        ? decoded['data'] as List<dynamic>
        : (decoded as List<dynamic>);

    return arr
        .map<double?>((e) {
          if (e == null) return null;
          if (e is num) return e.toDouble();
          return double.tryParse(e.toString());
        })
        .toList(growable: false);
  }

  Future<double?> priceBySymbol(String symbol) async {
    final list = await pricesBySymbols([symbol]);
    return list.isEmpty ? null : list.first;
  }

  void close() => _client.close();
}
