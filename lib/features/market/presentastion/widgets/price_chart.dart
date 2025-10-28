import 'package:crypto_mvp_getx/features/market/presentastion/pages/fullscreen_chart_page.dart';
import 'package:crypto_mvp_getx/features/market/presentastion/widgets/chandles_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/market_controller.dart';

Widget priceChartWidget(BuildContext context, MarketController controller) {
  return Row(
    children: [
      // ---- Price chart section ----
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF121A2B),
            borderRadius: BorderRadius.circular(16),
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
                        ex ? Icons.unfold_less : Icons.unfold_more,
                        color: Colors.white70,
                      ),
                      onPressed: controller.toggleChartExpanded,
                    );
                  }),
                  IconButton(
                    tooltip: 'Fullscreen',
                    icon: const Icon(Icons.fullscreen, color: Colors.white70),
                    onPressed: () => Get.to(() => const FullscreenChartPage()),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Timeframe chips
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  children: ['1d', '7d', '30d'].map((itv) {
                    final label = itv;
                    final selected = controller.selectedInterval.value == itv;
                    return ChoiceChip(
                      selected: selected,
                      label: Text(
                        label,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFF9AA4B2),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      pressElevation: 0,
                      selectedColor: const Color(0xFF10B981),
                      backgroundColor: const Color(0xFF0F172A),
                      onSelected: (_) => controller.changeInterval(itv),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: selected
                              ? const Color(0xFF10B981)
                              : const Color(0xFF1F2A44),
                        ),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 1,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                final h = controller.chartExpanded.value ? 460.0 : 240.0;
                final data = controller.candles;
                return Container(
                  height: h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E1627),
                    borderRadius: BorderRadius.circular(16),
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
                            style: TextStyle(color: Colors.white54),
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
            ],
          ),
        ),
      ),
    ],
  );
}
