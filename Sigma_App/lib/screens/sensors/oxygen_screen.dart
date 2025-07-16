import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'dart:math' as math;

class OxygenScreen extends StatefulWidget {
  final String childId;

  const OxygenScreen({super.key, required this.childId});

  @override
  _OxygenScreenState createState() => _OxygenScreenState();
}

class _OxygenScreenState extends State<OxygenScreen> {
  late List<ChartData> chartData;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    chartData = List.generate(60, (index) {
      final time = DateTime.now().subtract(Duration(minutes: 12 * (59 - index)));
      final baseOxygen = 97.0;
      final fluctuation = (math.Random().nextDouble() - 0.5) * 2;
      final value = baseOxygen + fluctuation;
      return ChartData(time, value.clamp(95, 100));
    });
    timer = Timer.periodic(const Duration(minutes: 5), (Timer t) {
      setState(() {
        chartData.removeAt(0);
        final newTime = DateTime.now();
        final baseOxygen = 97.0;
        final fluctuation = (math.Random().nextDouble() - 0.5) * 2;
        chartData.add(ChartData(newTime, (baseOxygen + fluctuation).clamp(95, 100)));
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
      appBar: AppBar(title: const Text('Oxygen')),
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
            title: const AxisTitle(text: 'Oxygen (%)'),
            minimum: 95.0,
            maximum: 100.0,
            interval: 0.5,
            majorGridLines: const MajorGridLines(width: 0.3, color: Color(0xFFD3D3D3)),
          ),
          series: <CartesianSeries<ChartData, DateTime>>[
            AreaSeries<ChartData, DateTime>(
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              name: 'Oxygen',
              color: const Color(0xFF66BB6A).withOpacity(0.7), // Green[400] equivalent
              borderColor: const Color(0xFF66BB6A), // Green[400]
              borderWidth: 2,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF66BB6A).withOpacity(0.7),
                  const Color(0xFFC8E6C9).withOpacity(0.5) // Green[100]
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              animationDuration: 500,
              markerSettings: const MarkerSettings(isVisible: true, color: Color(0xFF66BB6A), borderColor: Colors.white, borderWidth: 2),
            ),
          ],
          title: const ChartTitle(text: 'Oxygen Level Trend', textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
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