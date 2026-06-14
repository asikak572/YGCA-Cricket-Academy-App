import 'package:flutter/material.dart';

import 'widgets/ygca_app_bar.dart';

class FeePaymentScreen extends StatelessWidget {
  const FeePaymentScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: const YgcaAppBar(title: "Fee Payment"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _summaryCard(),
            const SizedBox(height: 16),
            _paymentMethod("UPI Payment", Icons.qr_code),
            _paymentMethod("Cash Payment", Icons.money),
            _paymentMethod("Bank Transfer", Icons.account_balance),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroon,
                  foregroundColor: gold,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Payment recorded successfully")),
                  );
                },
                child: const Text("Pay Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Text(
            "Arjun R",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text("Total Fee: ₹12,000", style: TextStyle(color: Colors.white70)),
          Text("Paid: ₹8,000", style: TextStyle(color: Colors.white70)),
          Text("Pending: ₹4,000", style: TextStyle(color: Color(0xFFD4AF37))),
        ],
      ),
    );
  }

  Widget _paymentMethod(String title, IconData icon) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: maroon,
          child: Icon(icon, color: gold),
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}