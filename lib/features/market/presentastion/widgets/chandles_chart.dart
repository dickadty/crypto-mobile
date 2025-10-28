import 'package:crypto_mvp_getx/data/models/chandle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CandlesChart extends StatelessWidget {
  final List<Candle> data;
  final Color panelColor;
  final Color gridColor;
  final Color bullColor;
  final Color bearColor;
  final ZoomPanBehavior? zoomPanBehavior;
  final TrackballBehavior? trackballBehavior;

  const CandlesChart({
    super.key,
    required this.data,
    required this.panelColor,
    required this.gridColor,
    required this.bullColor,
    required this.bearColor,
    this.zoomPanBehavior,
    this.trackballBehavior,
  });

  @override
  Widget build(BuildContext context) {
    final fmtTime = DateFormat('ha'); // "2PM"
    final fmtDate = DateFormat('MMM d'); // "Oct 27"

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      backgroundColor: panelColor,
      primaryXAxis: DateTimeAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(color: Color(0xFF1E293B), width: 1),
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 11),
        intervalType: DateTimeIntervalType.auto,
        axisLabelFormatter: (AxisLabelRenderDetails args) {
          final millis = args.value.toInt();
          final dt = DateTime.fromMillisecondsSinceEpoch(
            millis,
            isUtc: true,
          ).toLocal();

          // "2PM" -> "2pm"
          final timeStr = fmtTime.format(dt).toLowerCase();
          String label = timeStr;

          // Saat hari berganti (00:00), tampilkan tanggal di atasnya
          if (dt.hour == 0 && dt.minute == 0) {
            label = '${fmtDate.format(dt)}\n$timeStr';
          }
          return ChartAxisLabel(
            label,
            const TextStyle(color: Colors.white70, fontSize: 11),
          );
        },
      ),
      primaryYAxis: NumericAxis(
        opposedPosition: true, // Move Y-Axis to the right
        axisLine: const AxisLine(color: Color(0xFF1E293B), width: 1),
        majorGridLines: MajorGridLines(
          color: gridColor.withOpacity(.35),
          width: 1,
        ),
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 11),
      ),
      series: <CandleSeries<Candle, DateTime>>[
        CandleSeries<Candle, DateTime>(
          dataSource: data,
          xValueMapper: (c, _) => c.time,
          lowValueMapper: (c, _) => c.low,
          highValueMapper: (c, _) => c.high,
          openValueMapper: (c, _) => c.open,
          closeValueMapper: (c, _) => c.close,
          bearColor: bearColor,
          bullColor: bullColor,
          enableSolidCandles: true,
          animationDuration: 0,
        ),
      ],
      zoomPanBehavior: zoomPanBehavior,
      trackballBehavior: trackballBehavior,
    );
  }
}
