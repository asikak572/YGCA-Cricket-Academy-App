import 'package:flutter/material.dart';

class CoachAssignedStudentsScreen extends StatelessWidget {
  const CoachAssignedStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Students"),
      ),
      body: const Center(
        child: Text("Coach Assigned Students Screen"),
      ),
    );
  }
}