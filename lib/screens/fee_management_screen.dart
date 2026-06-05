import 'package:flutter/material.dart';

class FeeManagementScreen extends StatelessWidget {
  const FeeManagementScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Fee Management"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _summaryCard(),

            const SizedBox(height: 16),

            _feeTile(
              name: "Arjun R",
              batch: "Junior Batch",
              total: "₹12,000",
              paid: "₹12,000",
              pending: "₹0",
              status: "Paid",
              statusColor: Colors.green,
            ),

            _feeTile(
              name: "Kiran M",
              batch: "Junior Batch",
              total: "₹12,000",
              paid: "₹8,000",
              pending: "₹4,000",
              status: "Pending",
              statusColor: Colors.orange,
            ),

            _feeTile(
              name: "Priya S",
              batch: "Senior Batch",
              total: "₹15,000",
              paid: "₹10,000",
              pending: "₹5,000",
              status: "Pending",
              statusColor: Colors.orange,
            ),

            _feeTile(
              name: "Rahul K",
              batch: "Morning Batch",
              total: "₹12,000",
              paid: "₹12,000",
              pending: "₹0",
              status: "Paid",
              statusColor: Colors.green,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: maroon,
        foregroundColor: gold,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Add payment feature coming next")),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Payment"),
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
      child: Column(
        children: [
          const Text(
            "This Month Collection",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            "₹42,000",
            style: TextStyle(
              color: gold,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _miniStat("Paid", "₹42K")),
              Expanded(child: _miniStat("Pending", "₹9K")),
              Expanded(child: _miniStat("Students", "4")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _feeTile({
    required String name,
    required String batch,
    required String total,
    required String paid,
    required String pending,
    required String status,
    required Color statusColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: maroon,
                  child: Text(
                    name[0],
                    style: TextStyle(color: gold, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(batch, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(child: _amountBox("Total", total)),
                Expanded(child: _amountBox("Paid", paid)),
                Expanded(child: _amountBox("Pending", pending)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _amountBox(String title, String amount) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}