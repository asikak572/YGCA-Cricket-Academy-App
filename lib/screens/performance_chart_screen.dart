import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class PerformanceChartScreen extends StatelessWidget {
  const PerformanceChartScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  double _average(List<QueryDocumentSnapshot> docs, String key) {
    if (docs.isEmpty) return 0;

    int total = 0;

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += _toInt(data[key]);
    }

    return total / docs.length;
  }

  String _topPerformer(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return "No Data";

    String topName = "No Data";
    double topScore = -1;

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      final batting = _toInt(data['batting']);
      final bowling = _toInt(data['bowling']);
      final fielding = _toInt(data['fielding']);
      final fitness = _toInt(data['fitness']);

      final avg = (batting + bowling + fielding + fitness) / 4;

      if (avg > topScore) {
        topScore = avg;
        topName =
            data['studentName']?.toString() ??
            data['name']?.toString() ??
            'Unknown';
      }
    }

    return topName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Performance Analytics"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('performance_reports')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          final battingAvg = _average(docs, 'batting');
          final bowlingAvg = _average(docs, 'bowling');
          final fieldingAvg = _average(docs, 'fielding');
          final fitnessAvg = _average(docs, 'fitness');
          final topPlayer = _topPerformer(docs);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _heroCard(
                  totalReports: docs.length,
                  topPlayer: topPlayer,
                ),
                const SizedBox(height: 16),
                _summaryGrid(
                  battingAvg,
                  bowlingAvg,
                  fieldingAvg,
                  fitnessAvg,
                ),
                const SizedBox(height: 18),
                _sectionTitle("Skill Average Chart"),
                _barChart(
                  battingAvg,
                  bowlingAvg,
                  fieldingAvg,
                  fitnessAvg,
                ),
                const SizedBox(height: 18),
                _sectionTitle("Top Performers"),
                if (docs.isEmpty)
                  _emptyCard()
                else
                  ...docs.take(5).map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name =
                        data['studentName']?.toString() ??
                        data['name']?.toString() ??
                        'Unknown';

                    final batting = _toInt(data['batting']);
                    final bowling = _toInt(data['bowling']);
                    final fielding = _toInt(data['fielding']);
                    final fitness = _toInt(data['fitness']);
                    final avg =
                        ((batting + bowling + fielding + fitness) / 4).round();

                    return _topPlayerTile(
                      name: name,
                      avg: avg,
                      batch: data['batch']?.toString() ?? '',
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _heroCard({
    required int totalReports,
    required String topPlayer,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            "YGCA Performance Analytics",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: gold,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Skill-wise player performance overview",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _heroChip("Reports: $totalReports"),
              _heroChip("Top: $topPlayer"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.8)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: gold,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _summaryGrid(
    double batting,
    double bowling,
    double fielding,
    double fitness,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.35,
      children: [
        _statCard("Batting Avg", batting.round().toString(), Icons.sports_cricket, Colors.green),
        _statCard("Bowling Avg", bowling.round().toString(), Icons.sports_baseball, Colors.blue),
        _statCard("Fielding Avg", fielding.round().toString(), Icons.sports_handball, Colors.orange),
        _statCard("Fitness Avg", fitness.round().toString(), Icons.fitness_center, Colors.purple),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            "$value%",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: maroon,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _barChart(
    double batting,
    double bowling,
    double fielding,
    double fitness,
  ) {
    return Container(
      height: 270,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: BarChart(
        BarChartData(
          maxY: 100,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 35),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text("BAT");
                    case 1:
                      return const Text("BOWL");
                    case 2:
                      return const Text("FIELD");
                    case 3:
                      return const Text("FIT");
                    default:
                      return const Text("");
                  }
                },
              ),
            ),
          ),
          barGroups: [
            _bar(0, batting, Colors.green),
            _bar(1, bowling, Colors.blue),
            _bar(2, fielding, Colors.orange),
            _bar(3, fitness, Colors.purple),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y.clamp(0, 100),
          color: color,
          width: 24,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  Widget _topPlayerTile({
    required String name,
    required int avg,
    required String batch,
  }) {
    return Card(
      margin: const EdgeInsets.only(top: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: maroon,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : "?",
            style: TextStyle(color: gold, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(batch.isEmpty ? "No batch" : batch),
        trailing: Text(
          "$avg%",
          style: TextStyle(
            color: maroon,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        "No performance records available",
        textAlign: TextAlign.center,
      ),
    );
  }
}