import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SleepingQualityScreen extends StatefulWidget {
  const SleepingQualityScreen({super.key});

  @override
  _SleepingQualityScreenState createState() => _SleepingQualityScreenState();
}

class _SleepingQualityScreenState extends State<SleepingQualityScreen> {
  bool _isHistoryView = false;
  DateTime _selectedDate = DateTime(2025, 6, 30, 21, 50); // 09:50 PM EEST, June 30, 2025
  final Map<DateTime, List<Map<String, dynamic>>> _sleepData = {
    DateTime(2025, 6, 30, 21, 50): [
      {'startHour': 2.5, 'endHour': 4.5, 'isDeepSleep': true},  // 2:30 AM - 4:30 AM (Deep)
      {'startHour': 10.0, 'endHour': 12.0, 'isDeepSleep': false}, // 10:00 AM - 12:00 PM (Light)
      {'startHour': 15.5, 'endHour': 17.0, 'isDeepSleep': true}, // 3:30 PM - 5:00 PM (Deep)
    ],
    DateTime(2025, 6, 29): [
      {'startHour': 1.0, 'endHour': 3.0, 'isDeepSleep': false}, // 1:00 AM - 3:00 AM (Light)
      {'startHour': 8.5, 'endHour': 10.5, 'isDeepSleep': true}, // 8:30 AM - 10:30 AM (Deep)
      {'startHour': 14.0, 'endHour': 15.5, 'isDeepSleep': false}, // 2:00 PM - 3:30 PM (Light)
    ],
    DateTime(2025, 6, 28): [
      {'startHour': 4.0, 'endHour': 6.0, 'isDeepSleep': true},  // 4:00 AM - 6:00 AM (Deep)
      {'startHour': 11.0, 'endHour': 13.0, 'isDeepSleep': false}, // 11:00 AM - 1:00 PM (Light)
      {'startHour': 16.5, 'endHour': 18.0, 'isDeepSleep': true}, // 4:30 PM - 6:00 PM (Deep)
    ],
    DateTime(2025, 6, 27): [
      {'startHour': 3.5, 'endHour': 5.5, 'isDeepSleep': false}, // 3:30 AM - 5:30 AM (Light)
      {'startHour': 9.5, 'endHour': 11.5, 'isDeepSleep': true}, // 9:30 AM - 11:30 AM (Deep)
      {'startHour': 13.5, 'endHour': 15.0, 'isDeepSleep': false}, // 1:30 PM - 3:00 PM (Light)
    ],
    DateTime(2025, 6, 26): [
      {'startHour': 5.0, 'endHour': 7.0, 'isDeepSleep': true},  // 5:00 AM - 7:00 AM (Deep)
      {'startHour': 12.0, 'endHour': 14.0, 'isDeepSleep': false}, // 12:00 PM - 2:00 PM (Light)
      {'startHour': 17.0, 'endHour': 18.5, 'isDeepSleep': true}, // 5:00 PM - 6:30 PM (Deep)
    ],
    DateTime(2025, 6, 25): [
      {'startHour': 2.0, 'endHour': 4.0, 'isDeepSleep': false}, // 2:00 AM - 4:00 AM (Light)
      {'startHour': 7.5, 'endHour': 9.5, 'isDeepSleep': true},  // 7:30 AM - 9:30 AM (Deep)
      {'startHour': 15.0, 'endHour': 16.5, 'isDeepSleep': false}, // 3:00 PM - 4:30 PM (Light)
    ],
    DateTime(2025, 6, 24): [
      {'startHour': 6.0, 'endHour': 8.0, 'isDeepSleep': true},  // 6:00 AM - 8:00 AM (Deep)
      {'startHour': 10.5, 'endHour': 12.5, 'isDeepSleep': false}, // 10:30 AM - 12:30 PM (Light)
      {'startHour': 18.0, 'endHour': 19.5, 'isDeepSleep': true}, // 6:00 PM - 7:30 PM (Deep)
    ],
  };

  List<SleepDataPoint> _getChartData(List<Map<String, dynamic>> sleepSegments) {
    final dataPoints = <SleepDataPoint>[];
    double lastHour = 0.0;
    dataPoints.add(SleepDataPoint(lastHour, 0)); // Start at midnight (non-sleep)
    for (var segment in sleepSegments) {
      final startHour = segment['startHour'] as double;
      final endHour = segment['endHour'] as double;
      final isDeepSleep = segment['isDeepSleep'] as bool;

      // Add non-sleep gap if there's a break
      if (startHour > lastHour) {
        dataPoints.add(SleepDataPoint(startHour, 0)); // Non-sleep gap
      }
      dataPoints.add(SleepDataPoint(startHour, isDeepSleep ? 1 : 0.5));
      dataPoints.add(SleepDataPoint(endHour, isDeepSleep ? 1 : 0.5));
      lastHour = endHour;
    }
    // Add non-sleep gap to the end if not at 24
    if (lastHour < 24) {
      dataPoints.add(SleepDataPoint(lastHour, 0));
      dataPoints.add(SleepDataPoint(24, 0)); // End at midnight (non-sleep)
    }
    return dataPoints;
  }

  @override
  Widget build(BuildContext context) {
    final lastDayData = _sleepData[DateTime(2025, 6, 30, 21, 50)]!;
    final chartData = _getChartData(lastDayData);
    final isDeepSleep = lastDayData.any((segment) => segment['isDeepSleep'] as bool);

    return Scaffold(
      appBar: AppBar(title: const Text('Sleeping Quality')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            if (!_isHistoryView) ...[
              SizedBox(height: 20.h),
              Text(
                'Sleep Segments: ${lastDayData.map((seg) => '${DateFormat('hh:mm a').format(DateTime(2025, 6, 30, seg['startHour'].floor(), ((seg['startHour'] % 1) * 60).round()))} - ${DateFormat('hh:mm a').format(DateTime(2025, 6, 30, seg['endHour'].floor(), ((seg['endHour'] % 1) * 60).round()))} (${seg['isDeepSleep'] ? 'Deep' : 'Light'})').join(', ')} on ${DateFormat('EEEE, MMMM d, yyyy').format(DateTime(2025, 6, 30))}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 20.h),
              SizedBox(
                height: 300.h, // Increased chart height
                child: SfCartesianChart(
                  primaryXAxis: NumericAxis(
                    minimum: 0,
                    maximum: 24,
                    interval: 2,
                    title: AxisTitle(text: 'Hour of Day'),
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    maximum: 1,
                    interval: 0.5,
                    title: AxisTitle(text: 'Sleep Depth'),
                    labelFormat: '{value}',
                  ),
                  series: <CartesianSeries<SleepDataPoint, double>>[
                    LineSeries<SleepDataPoint, double>(
                      dataSource: chartData,
                      xValueMapper: (SleepDataPoint data, _) => data.hour,
                      yValueMapper: (SleepDataPoint data, _) => data.depth,
                      color: Colors.blue, // Consistent color for clarity
                      width: 2,
                      dashArray: const <double>[5, 3], // Dashed line style
                      pointColorMapper: (SleepDataPoint data, _) =>
                          data.depth == 0 ? Colors.grey : (data.depth == 1 ? Colors.green : Colors.orange),
                    ),
                  ],
                  tooltipBehavior: TooltipBehavior(enable: true),
                ),
              ),
              Text(
                'Contains Deep Sleep: ${isDeepSleep ? 'Yes' : 'No'}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isHistoryView = true;
                  });
                },
                child: const Text('History'),
              ),
            ] else ...[
              Text(
                'Sleep History for Last Week',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: ListView.builder(
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final date = DateTime(2025, 6, 30).subtract(Duration(days: index));
                    final data = _sleepData[date] ?? [
                      {'startHour': 7.0, 'endHour': 8.0, 'isDeepSleep': false},
                    ];
                    final chartData = _getChartData(data);
                    final isDeepSleep = data.any((segment) => segment['isDeepSleep'] as bool);

                    return ListTile(
                      title: Text(DateFormat('EEEE, MMMM d').format(date)),
                      subtitle: Text(
                        'Sleep Segments: ${data.map((seg) => '${DateFormat('hh:mm a').format(DateTime(date.year, date.month, date.day, seg['startHour'].floor(), ((seg['startHour'] % 1) * 60).round()))} - ${DateFormat('hh:mm a').format(DateTime(date.year, date.month, date.day, seg['endHour'].floor(), ((seg['endHour'] % 1) * 60).round()))} (${seg['isDeepSleep'] ? 'Deep' : 'Light'})').join(', ')}',
                      ),
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                          _isHistoryView = false;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
            if (_isHistoryView)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isHistoryView = false;
                  });
                },
                child: const Text('Back'),
              ),
          ],
        ),
      ),
    );
  }
}

class SleepDataPoint {
  final double hour;
  final double depth;

  SleepDataPoint(this.hour, this.depth);
}