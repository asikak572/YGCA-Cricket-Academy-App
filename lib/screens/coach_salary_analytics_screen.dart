import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoachSalaryAnalyticsScreen extends StatelessWidget {
  const CoachSalaryAnalyticsScreen({super.key});

  static const Color maroon = Color(0xFF7F0000);
  static const Color gold = Color(0xFFD4AF37);
  static const Color border = Color(0xFFE2E8F0);
  static const Color bg = Color(0xFFF8FAFC);

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Coach Salary Analytics"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('coaches')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final coaches = snapshot.data?.docs ?? [];

          int totalExpense = 0;
          int highestSalary = 0;
          String highestCoach = "N/A";

          for (final doc in coaches) {
            final data = doc.data() as Map<String, dynamic>;

            final salary = _toInt(data['salary']);

            totalExpense += salary;

            if (salary > highestSalary) {
              highestSalary = salary;
              highestCoach =
                  data['name']?.toString() ??
                  "Unknown Coach";
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: maroon,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "YGCA Salary Dashboard",
                        style: TextStyle(
                          color: gold,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Coach salary analytics and expense overview",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.3,
                  children: [
                    _statCard(
                      "Total Coaches",
                      coaches.length.toString(),
                      Icons.people,
                      Colors.blue,
                    ),
                    _statCard(
                      "Monthly Expense",
                      "₹$totalExpense",
                      Icons.payments,
                      Colors.green,
                    ),
                    _statCard(
                      "Highest Salary",
                      "₹$highestSalary",
                      Icons.workspace_premium,
                      Colors.orange,
                    ),
                    _statCard(
                      "Top Coach",
                      highestCoach,
                      Icons.emoji_events,
                      Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Coach Salary Ranking",
                    style: TextStyle(
                      color: maroon,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                if (coaches.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "No coaches found",
                      ),
                    ),
                  )
                else
                  ...coaches.map((doc) {
                    final data =
                        doc.data() as Map<String, dynamic>;

                    final name =
                        data['name']?.toString() ??
                        'Unknown Coach';

                    final batch =
                        data['batch']?.toString() ?? '';

                    final salary =
                        _toInt(data['salary']);

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        side:
                            const BorderSide(color: border),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: maroon,
                          child: Text(
                            name.isNotEmpty
                                ? name[0].toUpperCase()
                                : "?",
                            style: TextStyle(
                              color: gold,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          batch.isEmpty
                              ? "No Batch"
                              : batch,
                        ),
                        trailing: Text(
                          "₹$salary",
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}