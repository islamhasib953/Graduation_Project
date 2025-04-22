import 'package:flutter/material.dart';

class OxygenScreen extends StatelessWidget {
  const OxygenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oxygen')),
      body: const Center(child: Text('Oxygen Screen')),
    );
  }
}