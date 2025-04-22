import 'package:flutter/material.dart';

class HeartRateScreen extends StatelessWidget {
  const HeartRateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Heart Rate')),
      body: const Center(child: Text('Heart Rate Screen')),
    );
  }
}