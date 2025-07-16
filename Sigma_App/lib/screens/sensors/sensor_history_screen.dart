import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/sensor_cubit.dart';
import 'package:segma/models/sensor_data_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SensorHistoryScreen extends StatefulWidget {
  final String childId;
  final String type;

  const SensorHistoryScreen({super.key, required this.childId, required this.type});

  @override
  _SensorHistoryScreenState createState() => _SensorHistoryScreenState();
}

class _SensorHistoryScreenState extends State<SensorHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SensorCubit>().fetchHistory(widget.childId, widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.type} History')),
      body: BlocBuilder<SensorCubit, SensorState>(
        builder: (context, state) {
          if (state is SensorLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SensorHistoryLoaded) {
            final history = state.history;
            return SingleChildScrollView(
              child: Column(
                children: [
                  SfCartesianChart(
                    primaryXAxis: DateTimeAxis(),
                    primaryYAxis: NumericAxis(),
                    series: <CartesianSeries<SensorDataModel, DateTime>>[
                      LineSeries<SensorDataModel, DateTime>(
                        dataSource: history,
                        xValueMapper: (SensorDataModel data, _) => data.createdAt!,
                        yValueMapper: (SensorDataModel data, _) {
                          switch (widget.type.toLowerCase()) {
                            case 'temperature': return data.temperature;
                            case 'heart rate': return data.bpm;
                            case 'oxygen': return data.spo2;
                            case 'sleep quality': return data.ir; // Placeholder
                            default: return 0.0;
                          }
                        },
                      ),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final data = history[index];
                      return ListTile(
                        title: Text('${widget.type}: ${getValue(data)}'),
                        subtitle: Text('Date: ${data.createdAt?.toLocal()}'),
                      );
                    },
                  ),
                ],
              ),
            );
          }
          if (state is SensorError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  String getValue(SensorDataModel data) {
    switch (widget.type.toLowerCase()) {
      case 'temperature': return '${data.temperature?.toStringAsFixed(1) ?? 'N/A'}°C';
      case 'heart rate': return '${data.bpm?.toStringAsFixed(0) ?? 'N/A'} bpm';
      case 'oxygen': return '${data.spo2?.toStringAsFixed(0) ?? 'N/A'}%';
      case 'sleep quality': return '${data.ir?.toStringAsFixed(0) ?? 'N/A'}%';
      default: return 'N/A';
    }
  }
}