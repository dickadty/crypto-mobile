import 'dart:math' as math;
import 'package:crypto_mvp_getx/features/market/presentastion/widgets/chandles_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/assets.dart';
import '../controllers/market_controller.dart';
import 'fullscreen_chart_page.dart';

class MarketPage extends GetView<MarketController> {
  const MarketPage({super.key});

  Color get _bg => const Color(0xFF0B1220);
  Color get _panel => const Color(0xFF121A2B);
  Color get _muted => const Color(0xFF9AA4B2);
  BorderRadius get _radius => BorderRadius.circular(16);

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Obx(() {
          final slug = controller.selected.value ?? '';
          final info = slug.isEmpty ? null : controller.infoBySlug(slug);
          final name = info?.name ?? (slug.isEmpty ? '—' : _titleCase(slug));
          final symbol = info?.symbol ?? slug.toUpperCase();
          final price = controller.lastPrice.value;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Header ----
                Row(
                  children: [
                    _iconBtn(
                      context,
                      Icons.arrow_back,
                      () => Navigator.maybePop(context),
                    ),
                    const Spacer(),
                    _iconBtn(context, Icons.star_border, () {}),
                    const SizedBox(width: 8),
                    _iconBtn(context, Icons.ios_share, () {}),
                  ],
                ),
                const SizedBox(height: 16),

                // ---- Coin + ticker + dropdown aset ----
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF1C2843), Color(0xFF0E172B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.token, color: Colors.white70),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          symbol,
                          style: TextStyle(
                            color: _muted,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: _panel,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1E293B),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: _panel,
                          value: controller.selected.value,
                          items: controller.assetInfos
                              .map(
                                (a) => DropdownMenuItem(
                                  value: a.slug,
                                  child: Text(
                                    a.name,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) controller.changeAsset(val);
                          },
                          icon: const Icon(
                            Icons.expand_more,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ---- Price + badges ----
                Text(
                  price > 0 ? fmt.format(price) : '--',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _changeBadge(_mockChangeStr(0.08), '24h', positive: true),
                    _changeBadge(_mockChangeStr(0.152), '7d', positive: true),
                  ],
                ),

                const SizedBox(height: 16),
                Text(
                  '$name is a crypto asset displayed with real-time price and candlestick chart powered by CoinCap.',
                  style: TextStyle(color: _muted, fontSize: 14.5, height: 1.45),
                ),

                const SizedBox(height: 20),

                // ---- Price Chart card ----
                Container(
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius: _radius,
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + actions
                      Row(
                        children: [
                          const Text(
                            'Price Chart',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          // Perlebar / Kecilkan
                          Obx(() {
                            final ex = controller.chartExpanded.value;
                            return IconButton(
                              tooltip: ex ? 'Kecilkan' : 'Perlebar',
                              icon: Icon(
                                ex ? Icons.unfold_less : Icons.unfold_more,
                                color: Colors.white70,
                              ),
                              onPressed: controller.toggleChartExpanded,
                            );
                          }),
                          // Fullscreen
                          IconButton(
                            tooltip: 'Fullscreen',
                            icon: const Icon(
                              Icons.fullscreen,
                              color: Colors.white70,
                            ),
                            onPressed: () =>
                                Get.to(() => const FullscreenChartPage()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Timeframe chips
                      Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 8,
                          children: kTimeframes.entries.map((e) {
                            final label = e.key; // mis. '5m'
                            final value = e.value; // mis. 'm5'
                            final selected =
                                controller.selectedInterval.value == value;
                            return ChoiceChip(
                              selected: selected,
                              label: Text(
                                label,
                                style: TextStyle(
                                  color: selected ? Colors.white : _muted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              pressElevation: 0,
                              selectedColor: const Color(0xFF10B981),
                              backgroundColor: const Color(0xFF0F172A),
                              onSelected: (_) =>
                                  controller.changeInterval(value),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: selected
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF1F2A44),
                                ),
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 1,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Chart container (tinggi dinamis)
                      Obx(() {
                        final h = controller.chartExpanded.value
                            ? 460.0
                            : 240.0;
                        return Container(
                          height: h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E1627),
                            borderRadius: _radius,
                            border: Border.all(
                              color: const Color(0xFF1E293B),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Obx(() {
                            final data = controller.candles;
                            if (data.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No data',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              );
                            }
                            // Candlesticks (zoom/pan aktif di widget)
                            return CandlesChart(
                              data: data.toList(),
                              panelColor: const Color(0xFF0E1627),
                              gridColor: const Color(0xFF20304D),
                              bullColor: const Color(0xFF10B981),
                              bearColor: const Color(0xFFF87171),
                            );
                          }),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ---- Bottom metrics (DINAMIS) ----
                Obx(() {
                  String _fmtCurrency(double? v) {
                    if (v == null) return '—';
                    final s = v.abs() >= 1000 ? _fmt(v) : v.toStringAsFixed(2);
                    return '\$$s';
                  }

                  return GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: MediaQuery.of(context).size.width > 680
                        ? 4
                        : 2,
                    shrinkWrap: true,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3.3,
                    children: [
                      _StatTile(
                        title: 'High 24h',
                        value: _fmtCurrency(controller.high24h.value),
                      ),
                      _StatTile(
                        title: 'Low 24h',
                        value: _fmtCurrency(controller.low24h.value),
                      ),
                      _StatTile(
                        title: 'Market Cap',
                        value: _fmtCurrency(controller.marketCap.value),
                      ),
                      _StatTile(
                        title: '24h Volume',
                        value: _fmtCurrency(controller.volume24h.value),
                      ),
                    ],
                  );
                }),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ---- Utils / UI helpers ----
  Widget _iconBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }

  String _titleCase(String slug) {
    if (slug.isEmpty) return slug;
    return slug[0].toUpperCase() + slug.substring(1);
  }

  // Badge perubahan dummy (bisa diganti perhitungan dari candle 24h)
  String _mockChangeStr(double f) {
    final rnd = (math.Random().nextDouble() * f * 100);
    return '+${rnd.toStringAsFixed(2)}%';
  }

  Widget _changeBadge(String change, String window, {bool positive = true}) {
    final Color bg = positive
        ? const Color(0xFF08381F)
        : const Color(0xFF3A1010);
    final Color fg = positive
        ? const Color(0xFF46D39A)
        : const Color(0xFFF87171);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withOpacity(.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? Icons.arrow_outward : Icons.south_east,
            size: 16,
            color: fg,
          ),
          const SizedBox(width: 6),
          Text(
            '$change  ',
            style: TextStyle(
              color: fg,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: fg.withOpacity(.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              window,
              style: TextStyle(
                color: fg,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Tile metric bawah ----
class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  const _StatTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121A2B),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF9AA4B2),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Util format angka ribuan ----
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
