import 'package:crypto_mvp_getx/features/market/presentastion/controllers/market_controller.dart';
import 'package:crypto_mvp_getx/features/market/presentastion/widgets/chandles_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class FullscreenChartPage extends GetView<MarketController> {
  const FullscreenChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        title: const Text('Fullscreen Chart'),
        actions: [
          IconButton(
            tooltip: 'Reset zoom',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // cara simpel reset: reload candle (tanpa ubah interval)
              final slug = controller.selected.value;
              if (slug != null) {
                controller.changeInterval(controller.selectedInterval.value);
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        final data = controller.candles;
        if (data.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        // Perbesar area chart (tanpa card)
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: CandlesChart(
            data: data.toList(),
            panelColor: const Color(0xFF0B1220),
            gridColor: const Color(0xFF20304D),
            bullColor: const Color(0xFF10B981),
            bearColor: const Color(0xFFF87171),
            // Bisa custom behavior untuk fullscreen
            zoomPanBehavior: ZoomPanBehavior(
              enablePinching: true,
              enablePanning: true,
              enableDoubleTapZooming: true,
              zoomMode: ZoomMode.x,
              maximumZoomLevel: 0.05, // lebih dekat
              enableMouseWheelZooming: true,
              enableSelectionZooming: true,
            ),
            trackballBehavior: TrackballBehavior(
              enable: true,
              activationMode: ActivationMode.singleTap,
              tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
              lineColor: const Color(0xFF334155),
              lineWidth: 1,
              tooltipSettings: const InteractiveTooltip(
                enable: true,
                color: Color(0xFF1F2937),
                textStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      }),
    );
  }
}
