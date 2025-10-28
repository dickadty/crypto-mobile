import 'dart:math' as math;
import 'package:crypto_mvp_getx/features/market/presentastion/widgets/badge_widget.dart';
import 'package:crypto_mvp_getx/features/market/presentastion/widgets/chandles_chart.dart';
import 'package:crypto_mvp_getx/features/market/presentastion/widgets/icon_button.dart';
import 'package:crypto_mvp_getx/features/market/presentastion/widgets/stat_tile.dart';
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

          final pct = controller.change24hPct.value;
          final up = (pct ?? 0) >= 0;
          final badgeStr = pct == null
              ? '—'
              : '${up ? '+' : ''}${pct.toStringAsFixed(2)}%';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Header ----
                Row(
                  children: [
                    iconBtn(
                      context,
                      Icons.arrow_back,
                      () => Navigator.maybePop(context),
                    ),
                    const Spacer(),
                    iconBtn(context, Icons.star_border, () {}),
                    const SizedBox(width: 8),
                    iconBtn(context, Icons.ios_share, () {}),
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
                            fontSize: 20,
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
                  ],
                ),
                const SizedBox(height: 16),
                // ---- Price ----
                Text(
                  price > 0 ? fmt.format(price) : '--',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),

                // ---- Badges ----
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    changeBadge(badgeStr, '24h', positive: up),
                    changeBadge(_mockChangeStr(0.05), '7d', positive: true),
                  ],
                ),
                const SizedBox(height: 16),

                // ---- Description ----
                Text(
                  '$name is a crypto asset displayed with real-time price and candlestick chart powered by CoinCap.',
                  style: TextStyle(color: _muted, fontSize: 14.5, height: 1.45),
                ),

                const SizedBox(height: 20),
                // ---- Price Chart card ----
                Row(
                  children: [
                    // ---- Price chart section ----
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: _panel,
                          borderRadius: _radius,
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                Obx(() {
                                  final ex = controller.chartExpanded.value;
                                  return IconButton(
                                    tooltip: ex ? 'Kecilkan' : 'Perlebar',
                                    icon: Icon(
                                      ex
                                          ? Icons.unfold_less
                                          : Icons.unfold_more,
                                      color: Colors.white70,
                                    ),
                                    onPressed: controller.toggleChartExpanded,
                                  );
                                }),
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
                            // Chart container (tinggi dinamis)
                            Obx(() {
                              final h = controller.chartExpanded.value
                                  ? 460.0
                                  : 240.0;
                              final data = controller.candles;
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
                                child: data.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No data',
                                          style: TextStyle(
                                            color: Colors.white54,
                                          ),
                                        ),
                                      )
                                    : CandlesChart(
                                        data: data.toList(),
                                        panelColor: const Color(0xFF0E1627),
                                        gridColor: const Color(0xFF20304D),
                                        bullColor: const Color(0xFF10B981),
                                        bearColor: const Color(0xFFF87171),
                                      ),
                              );
                            }),
                            // Timeframe dropdown
                            Align(
                              alignment: Alignment.centerRight,
                              child: DropdownButton<String>(
                                value: controller.selectedInterval.value,
                                items: kIntervals.map((itv) {
                                  return DropdownMenuItem<String>(
                                    value: itv,
                                    child: Text(
                                      itv,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    controller.changeInterval(val);
                                  }
                                },
                                dropdownColor: _panel,
                                icon: const Icon(
                                  Icons.expand_more,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Obx(() {
                  String _fmtCurrency(double? v) {
                    if (v == null) return '—';
                    final abs = v.abs();
                    if (abs >= 1e12)
                      return '\$${(v / 1e12).toStringAsFixed(2)}T';
                    if (abs >= 1e9) return '\$${(v / 1e9).toStringAsFixed(2)}B';
                    if (abs >= 1e6) return '\$${(v / 1e6).toStringAsFixed(2)}M';
                    if (abs >= 1e3) return '\$${(v / 1e3).toStringAsFixed(2)}K';
                    return '\$${v.toStringAsFixed(2)}';
                  }

                  return GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3.3,
                    crossAxisCount: 2, // 2 columns for smaller screens
                    children: [
                      StatTile(
                        title: 'High 24h',
                        value: _fmtCurrency(controller.high24h.value),
                      ),
                      StatTile(
                        title: 'Low 24h',
                        value: _fmtCurrency(controller.low24h.value),
                      ),
                      StatTile(
                        title: 'Market Cap',
                        value: _fmtCurrency(controller.marketCap.value),
                      ),
                      StatTile(
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

  String _titleCase(String slug) =>
      slug.isEmpty ? slug : slug[0].toUpperCase() + slug.substring(1);

  String _mockChangeStr(double f) {
    final rnd = (math.Random().nextDouble() * f * 100);
    return '+${rnd.toStringAsFixed(2)}%';
  }
}
