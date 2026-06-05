import 'package:flutter/material.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final payments = [
      {
        "name": "Arjun R",
        "amount": "₹5,000",
        "date": "10 Jun 2026",
        "status": "Paid",
      },
      {
        "name": "Priya S",
        "amount": "₹4,500",
        "date": "08 Jun 2026",
        "status": "Paid",
      },
      {
        "name": "Rahul K",
        "amount": "₹3,000",
        "date": "05 Jun 2026",
        "status": "Paid",
      },
      {
        "name": "Siva T",
        "amount": "₹5,000",
        "date": "01 Jun 2026",
        "status": "Paid",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment History"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: maroon,
                child: Icon(
                  Icons.payments,
                  color: gold,
                ),
              ),
              title: Text(
                payment["name"]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "${payment["date"]} • ${payment["amount"]}",
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Paid",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}