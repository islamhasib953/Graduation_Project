import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'dart:math' as math;

class TemperatureScreen extends StatefulWidget {
  final String childId;

  const TemperatureScreen({super.key, required this.childId});

  @override
  _TemperatureScreenState createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  late List<ChartData> chartData;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    // Generate 120 data points for the last 24 hours from current time (06:23 PM EEST, July 04, 2025)
    chartData = List.generate(120, (index) {
      final time = DateTime.now().subtract(Duration(minutes: 12 * (119 - index)));
      double baseTemp;
      final fluctuation = (math.Random().nextDouble() - 0.5) * 0.3; // Small fluctuation for realism

      // Temperature based on time of day for a 7-year-old, adjusted for wrist sensor
      if (time.hour >= 6 && time.hour < 9) { // Morning rest (6 AM - 9 AM)
        baseTemp = 36.5;
      } else if (time.hour >= 10 && time.hour < 15) { // Playtime (10 AM - 3 PM)
        baseTemp = 37.2;
      } else if (time.hour >= 15 && time.hour < 19) { // Evening activity (3 PM - 7 PM)
        baseTemp = 37.1;
      } else { // Night sleep (8 PM - 5 AM)
        baseTemp = 36.2;
      }

      final value = (baseTemp + fluctuation).clamp(36.0, 38.0); // Clamp to realistic range for wrist sensor
      return ChartData(time, value);
    });
    timer = Timer.periodic(const Duration(minutes: 5), (Timer t) {
      setState(() {
        chartData.removeAt(0);
        final newTime = DateTime.now();
        double baseTemp;
        final fluctuation = (math.Random().nextDouble() - 0.5) * 0.3;

        if (newTime.hour >= 6 && newTime.hour < 9) {
          baseTemp = 36.5;
        } else if (newTime.hour >= 10 && newTime.hour < 15) {
          baseTemp = 37.5;
        } else if (newTime.hour >= 15 && newTime.hour < 19) {
          baseTemp = 37.1;
        } else {
          baseTemp = 36.2;
        }

        chartData.add(ChartData(newTime, (baseTemp + fluctuation).clamp(36.0, 38.0)));
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
      appBar: AppBar(title: const Text('Temperature')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: DateTimeAxis(
            title: const AxisTitle(text: 'Time (Last 24 Hours)'),
            dateFormat: DateFormat.Hm(),
            intervalType: DateTimeIntervalType.hours,
            interval: 4,
            majorGridLines: const MajorGridLines(width: 0),
            edgeLabelPlacement: EdgeLabelPlacement.shift,
          ),
          primaryYAxis: NumericAxis(
            title: const AxisTitle(text: 'Temperature (°C)'),
            minimum: 36.0,
            maximum: 38.5,
            interval: 0.5,
            majorGridLines: const MajorGridLines(width: 0.3, color: Color(0xFFD3D3D3)),
          ),
          series: <CartesianSeries<ChartData, DateTime>>[
            AreaSeries<ChartData, DateTime>(
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              name: 'Temperature',
              color: const Color(0xFFFFCA28).withOpacity(0.7),
              borderColor: const Color(0xFFFFCA28),
              borderWidth: 2,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFCA28).withOpacity(0.7),
                  const Color(0xFFFFECB3).withOpacity(0.5)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              animationDuration: 500,
              markerSettings: const MarkerSettings(isVisible: true, color: Color(0xFFFFCA28), borderColor: Colors.white, borderWidth: 2),
            ),
          ],
          title: const ChartTitle(text: 'Temperature Trend', textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          legend: const Legend(isVisible: true, position: LegendPosition.bottom),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            format: 'Time: point.x\nTemp: point.y °C',
          ),
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
