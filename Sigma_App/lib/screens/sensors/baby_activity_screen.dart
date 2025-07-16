import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:segma/cubits/sensor_cubit.dart';
import 'package:segma/screens/sensors/sensor_history_screen.dart';

class BabyActivityScreen extends StatelessWidget {
  const BabyActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Baby Activity')),
      body: const Center(child: Text('Baby Activity Screen')),
    );
  }
}
