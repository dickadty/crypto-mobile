class AssetInfo {
  final String slug; // id/slug, ex: "bitcoin"
  final String symbol; // ex: "BTC"
  final String name; // ex: "Bitcoin"
  final double? marketCapUsd; // bisa null jika dari list tanpa detail
  final double? volumeUsd24Hr; // bisa null jika dari list tanpa detail

  const AssetInfo({
    required this.slug,
    required this.symbol,
    required this.name,
    this.marketCapUsd,
    this.volumeUsd24Hr,
  });

  /// Parsing fleksibel: bisa {data:{...}} atau langsung {...}
  factory AssetInfo.fromJson(dynamic json) {
    final Map<String, dynamic> m =
        (json is Map<String, dynamic> && json['data'] is Map<String, dynamic>)
        ? (json['data'] as Map<String, dynamic>)
        : (json as Map<String, dynamic>);

    double? _d(x) => x == null
        ? null
        : (x is num ? x.toDouble() : double.tryParse(x.toString()));

    final id = (m['id'] ?? m['slug'] ?? '').toString();
    final sym = (m['symbol'] ?? '').toString();
    final nm = (m['name'] ?? '').toString();

    return AssetInfo(
      slug: id.toLowerCase(),
      symbol: sym.toUpperCase(),
      name: nm,
      marketCapUsd: _d(m['marketCapUsd']),
      volumeUsd24Hr: _d(m['volumeUsd24Hr']),
    );
  }

  /// Copy dengan override sebagian field (berguna saat "merge" detail)
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
