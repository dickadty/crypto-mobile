class AssetInfo {
  final String slug; // ex: "bitcoin" (id)
  final String symbol; // ex: "BTC"
  final String name; // ex: "Bitcoin"
  final double? marketCapUsd;
  final double? volumeUsd24Hr;

  const AssetInfo({
    required this.slug,
    required this.symbol,
    required this.name,
    this.marketCapUsd,
    this.volumeUsd24Hr,
  });

  factory AssetInfo.fromJson(dynamic json) {
    final Map<String, dynamic> root =
        (json is Map<String, dynamic> && json['data'] is Map<String, dynamic>)
            ? (json['data'] as Map<String, dynamic>)
            : (json as Map<String, dynamic>);

    double? _d(x) =>
        x == null ? null : (x is num ? x.toDouble() : double.tryParse('$x'));

    final id = (root['id'] ?? root['slug'] ?? '').toString();
    final sym = (root['symbol'] ?? '').toString();
    final nm = (root['name'] ?? '').toString();

    return AssetInfo(
      slug: id.toLowerCase(),
      symbol: sym.toUpperCase(),
      name: nm,
      marketCapUsd: _d(root['marketCapUsd']),
      volumeUsd24Hr: _d(root['volumeUsd24Hr']),
    );
  }

  AssetInfo copyWith({
    String? slug,
    String? symbol,
    String? name,
    double? marketCapUsd,
    double? volumeUsd24Hr,
  }) {
    return AssetInfo(
      slug: slug ?? this.slug,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      marketCapUsd: marketCapUsd ?? this.marketCapUsd,
      volumeUsd24Hr: volumeUsd24Hr ?? this.volumeUsd24Hr,
    );
  }
}
