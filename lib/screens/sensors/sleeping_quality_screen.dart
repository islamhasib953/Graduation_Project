import 'package:flutter/material.dart';

class SleepingQualityScreen extends StatelessWidget {
  const SleepingQualityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleeping Quality')),
      body: const Center(child: Text('Sleeping Quality Screen')),
    );
  }
}
