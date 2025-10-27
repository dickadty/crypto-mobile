import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:crypto_mvp_getx/data/models/chandle.dart'; // Pastikan model Candle diimport

class CandlesChart extends StatelessWidget {
  final List<Candle> data;
  final Color panelColor;
  final Color gridColor;
  final Color bullColor;
  final Color bearColor;

  // 🔧 Tambahan: perilaku zoom & pan bisa dipassing (opsional)
  final ZoomPanBehavior? zoomPanBehavior;
  final TrackballBehavior? trackballBehavior;

  const CandlesChart({
    super.key,
    required this.data,
    this.panelColor = const Color(0xFF0E1627),
    this.gridColor  = const Color(0xFF20304D),
    this.bullColor  = const Color(0xFF10B981),
    this.bearColor  = const Color(0xFFF87171),
    this.zoomPanBehavior,
    this.trackballBehavior,
  });

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      backgroundColor: panelColor,
      primaryXAxis: DateTimeAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        labelStyle: const TextStyle(color: Color(0xFF9AA4B2), fontSize: 10),
      ),
      primaryYAxis: NumericAxis(
        opposedPosition: true,
        labelStyle: const TextStyle(color: Color(0xFF9AA4B2), fontSize: 10),
        axisLine: const AxisLine(width: 0),
        majorGridLines: MajorGridLines(width: 1, color: gridColor),
      ),
      series: <CandleSeries<_P, DateTime>>[
        CandleSeries<_P, DateTime>(
          dataSource: data
              .map((c) => _P(t: c.time, o: c.open, h: c.high, l: c.low, c: c.close))
              .toList(),
          xValueMapper: (p, _) => p.t,
          lowValueMapper: (p, _) => p.l,
          highValueMapper: (p, _) => p.h,
          openValueMapper: (p, _) => p.o,
          closeValueMapper: (p, _) => p.c,
          enableSolidCandles: true,
          bearColor: bearColor,
          bullColor: bullColor,
          name: 'Price',
        ),
      ],
      // 🔎 Interaksi
      zoomPanBehavior: zoomPanBehavior ??
          ZoomPanBehavior(
            enablePanning: true,
            enablePinching: true,
            enableDoubleTapZooming: true,
            zoomMode: ZoomMode.x,           // zoom sumbu waktu
            maximumZoomLevel: 0.1,          // 10% dari lebar → zoom lebih dekat
            enableSelectionZooming: true,   // drag untuk zoom
          ),
      trackballBehavior: trackballBehavior ??
          TrackballBehavior(
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
            tooltipAlignment: ChartAlignment.near,
            tooltipSettings: const InteractiveTooltip(
              enable: true,
              color: Color(0xFF1F2937),
              textStyle: TextStyle(color: Colors.white),
            ),
            lineColor: const Color(0xFF334155),
            lineWidth: 1,
          ),
    );
  }
}

class _P {
  final DateTime t;
  final double o, h, l, c;
  _P({required this.t, required this.o, required this.h, required this.l, required this.c});
}
