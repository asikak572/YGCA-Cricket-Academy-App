import 'package:flutter/material.dart';

class CoachDashboard extends StatelessWidget {
  const CoachDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coach Dashboard')),
      body: const Center(
        child: Text(
          'Welcome Coach',
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}