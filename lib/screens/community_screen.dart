import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: const Center(child: Text('Community Screen')),
    );
  }
}