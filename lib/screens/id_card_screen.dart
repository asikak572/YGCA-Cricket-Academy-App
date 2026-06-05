import 'package:flutter/material.dart';

class IDCardScreen extends StatelessWidget {
  const IDCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const maroon = Color(0xFF7F0000);
    const gold = Color(0xFFD4AF37);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student ID Card"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: maroon,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "YOUNG GEN CRICKET ACADEMY",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: gold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: maroon,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Arjun R",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "ID : YGCA014",
                style: TextStyle(color: Colors.white70),
              ),

              const Text(
                "Batch : Morning Batch",
                style: TextStyle(color: Colors.white70),
              ),

              const Text(
                "Phone : 9876543210",
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "ACTIVE PLAYER",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}