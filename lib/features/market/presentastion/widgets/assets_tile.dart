import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/market_controller.dart';

class AssetTileLive extends StatelessWidget {
  final String slug;
  final String symbol;
  final String name;
  final VoidCallback onTap;

  const AssetTileLive({
    required this.slug,
    required this.symbol,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MarketController>();

    return Obx(() {
      // Ambil harga dan persentase perubahan secara real-time
      final price = c.prices[slug] ?? 0.0;
      final pct = c.pctChanges[slug] ?? 0.0;

      // Tentukan apakah persentase positif atau negatif
      final up = pct >= 0;
      final pctColor = up ? const Color(0xFF22C55E) : const Color(0xFFF43F5E);
      final pctStr = pct == 0.0
          ? '—'
          : '${up ? '+' : ''}${pct.toStringAsFixed(2)}%';

      // Ambil volume dari controller
      final volume = c.volumes[slug] ?? 0.0;
      final volumeStr = _fmtCompact(volume);

      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1A2440)),
          ),
          child: Row(
            children: [
              _assetIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          symbol,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Tampilkan volume dinamis
                    Text(
                      volume == 0.0 ? 'Vol: —' : 'Vol: $volumeStr',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price > 0 ? '\$${_fmt(price)}' : '--',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pctStr,
                    style: TextStyle(
                      color: pctColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _assetIcon() => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: const Color(0xFF0A1222),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF1A2440)),
    ),
    child: const Icon(Icons.currency_bitcoin_rounded, color: Colors.white70),
  );

  // Fungsi untuk memformat harga dengan tanda koma
  String _fmt(double v) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    final ints = parts[0];
    final buff = StringBuffer();
    for (int i = 0; i < ints.length; i++) {
      final idx = ints.length - i - 1;
      buff.write(ints[idx]);
      final pos = i + 1;
      if (pos % 3 == 0 && idx != 0) buff.write(',');
    }
    final rev = buff.toString().split('').reversed.join();
    return '$rev.${parts[1]}';
  }

  // Fungsi untuk memformat volume secara kompak
  String _fmtCompact(double v) {
    final abs = v.abs();
    if (abs >= 1e12) return '${(v / 1e12).toStringAsFixed(2)}T';
    if (abs >= 1e9) return '${(v / 1e9).toStringAsFixed(2)}B';
    if (abs >= 1e6) return '${(v / 1e6).toStringAsFixed(2)}M';
    if (abs >= 1e3) return '${(v / 1e3).toStringAsFixed(2)}K';
    return v.toStringAsFixed(2);
  }
}
