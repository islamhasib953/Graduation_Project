import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'dart:math' as math;

class HeartRateScreen extends StatefulWidget {
  final String childId;

  const HeartRateScreen({super.key, required this.childId});

  @override
  _HeartRateScreenState createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> {
  late List<ChartData> chartData;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    chartData = List.generate(60, (index) {
      final time = DateTime.now().subtract(Duration(minutes: 12 * (59 - index)));
      final baseRate = 75.0;
      final fluctuation = (math.Random().nextDouble() - 0.5) * 10;
      final value = baseRate + fluctuation;
      return ChartData(time, value.clamp(60, 100));
    });
    timer = Timer.periodic(const Duration(minutes: 5), (Timer t) {
      setState(() {
        chartData.removeAt(0);
        final newTime = DateTime.now();
        final baseRate = 75.0;
        final fluctuation = (math.Random().nextDouble() - 0.5) * 10;
        chartData.add(ChartData(newTime, (baseRate + fluctuation).clamp(60, 100)));
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Heart Rate')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: DateTimeAxis(
            title: const AxisTitle(text: 'Time (Last 12 Hours)'),
            dateFormat: DateFormat.Hm(),
            intervalType: DateTimeIntervalType.hours,
            interval: 2,
            majorGridLines: const MajorGridLines(width: 0),
            edgeLabelPlacement: EdgeLabelPlacement.shift,
          ),
          primaryYAxis: NumericAxis(
            title: const AxisTitle(text: 'Heart Rate (bpm)'),
            minimum: 60.0,
            maximum: 100.0,
            interval: 5,
            majorGridLines: const MajorGridLines(width: 0.3, color: Color(0xFFD3D3D3)),
          ),
          series: <CartesianSeries<ChartData, DateTime>>[
            AreaSeries<ChartData, DateTime>(
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              name: 'Heart Rate',
              color: const Color(0xFF42A5F5).withOpacity(0.7), // Blue[400] equivalent
              borderColor: const Color(0xFF42A5F5), // Blue[400]
              borderWidth: 2,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF42A5F5).withOpacity(0.7),
                  const Color(0xBBE3F2FD).withOpacity(0.5) // Blue[100]
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              animationDuration: 500,
              markerSettings: const MarkerSettings(isVisible: true, color: Color(0xFF42A5F5), borderColor: Colors.white, borderWidth: 2),
            ),
          ],
          title: const ChartTitle(text: 'Heart Rate Trend', textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          legend: const Legend(isVisible: true, position: LegendPosition.bottom),
          tooltipBehavior: TooltipBehavior(enable: true),
        ),
      ),
    );
  }
}

class ChartData {
  final DateTime x;
  final double y;

  ChartData(this.x, this.y);
}