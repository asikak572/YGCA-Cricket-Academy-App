import 'package:flutter/material.dart';

class DigitalIdCardScreen extends StatelessWidget {
  final String name;
  final String rollNo;
  final String batch;
  final String parentName;
  final String phone;
  final String photoUrl;

  const DigitalIdCardScreen({
    super.key,
    required this.name,
    required this.rollNo,
    required this.batch,
    required this.parentName,
    required this.phone,
    required this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    const maroon = Color(0xFF7F0000);
    const gold = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text("Digital ID Card"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          width: 330,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: gold, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/ygca_logo.jpg',
                height: 70,
              ),
              const SizedBox(height: 8),
              const Text(
                "YOUNG GEN CRICKET ACADEMY",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: maroon,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: maroon,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "STUDENT ID CARD",
                  style: TextStyle(
                    color: gold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              CircleAvatar(
                radius: 48,
                backgroundColor: maroon,
                backgroundImage:
                    photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                child: photoUrl.isEmpty
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "S",
                        style: const TextStyle(
                          color: gold,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: maroon,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              _row("Roll No", rollNo),
              _row("Batch", batch),
              _row("Parent", parentName),
              _row("Phone", phone),
              _row("Status", "Active"),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: maroon,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  "Discipline • Passion • Success",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            value.isEmpty ? "-" : value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}