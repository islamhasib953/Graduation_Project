import 'package:flutter/material.dart';

class TemperatureScreen extends StatelessWidget {
  const TemperatureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Temperature')),
      body: const Center(child: Text('Temperature Screen')),
    );
  }
}