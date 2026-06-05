import 'package:flutter/material.dart';

class LeaveRequestScreen extends StatelessWidget {
  const LeaveRequestScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final requests = [
      {
        "name": "Arjun R",
        "batch": "Morning Batch",
        "date": "12 Jun 2026",
        "reason": "Fever",
        "status": "Pending",
      },
      {
        "name": "Kiran M",
        "batch": "Evening Batch",
        "date": "10 Jun 2026",
        "reason": "Family function",
        "status": "Approved",
      },
      {
        "name": "Priya S",
        "batch": "Junior Batch",
        "date": "08 Jun 2026",
        "reason": "School exam",
        "status": "Rejected",
      },
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Leave Requests"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          final status = request["status"]!;

          Color statusColor = Colors.orange;
          if (status == "Approved") statusColor = Colors.green;
          if (status == "Rejected") statusColor = Colors.red;

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
                          request["name"]![0],
                          style: TextStyle(
                            color: gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(request["name"]!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(
                              request["batch"]!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _statusChip(status, statusColor),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _row("Leave Date", request["date"]!),
                  _row("Reason", request["reason"]!),

                  if (status == "Pending") ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Leave rejected"),
                                ),
                              );
                            },
                            icon: const Icon(Icons.close),
                            label: const Text("Reject"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: maroon,
                              foregroundColor: gold,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Leave approved"),
                                ),
                              );
                            },
                            icon: const Icon(Icons.check),
                            label: const Text("Approve"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: maroon,
        foregroundColor: gold,
        onPressed: () {
          _showLeaveForm(context);
        },
        icon: const Icon(Icons.add),
        label: const Text("New Leave"),
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showLeaveForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("New Leave Request"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "Student Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: "Leave Date",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Reason",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: maroon,
                foregroundColor: gold,
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Leave request submitted")),
                );
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }
}