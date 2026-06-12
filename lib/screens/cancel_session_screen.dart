import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CancelSessionScreen extends StatelessWidget {
  const CancelSessionScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

  Future<void> _cancelSession({
    required BuildContext context,
    required TextEditingController batchController,
    required TextEditingController dateController,
    required TextEditingController timeController,
    required TextEditingController reasonController,
  }) async {
    final batch = batchController.text.trim();
    final date = dateController.text.trim();
    final time = timeController.text.trim();
    final reason = reasonController.text.trim();

    if (batch.isEmpty || date.isEmpty || time.isEmpty || reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final cancelledDoc =
        await FirebaseFirestore.instance.collection('cancelled_sessions').add({
      'batch': batch,
      'date': date,
      'time': time,
      'reason': reason,
      'makeup': 'Not scheduled',
      'status': 'Cancelled',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('makeup_sessions').add({
      'cancelledSessionId': cancelledDoc.id,
      'batch': batch,
      'cancelledDate': date,
      'cancelledTime': time,
      'reason': reason,
      'makeupDate': '',
      'makeupTime': '',
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('notifications').add({
      'title': 'Session Cancelled',
      'message':
          '$batch session on $date at $time has been cancelled. Reason: $reason. Makeup session will be scheduled soon.',
      'targetRole': 'All',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Session cancelled and makeup session created"),
        ),
      );

      batchController.clear();
      dateController.clear();
      timeController.clear();
      reasonController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final batchController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final reasonController = TextEditingController();

    return Scaffold(
      backgroundColor: bg,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cancelled_sessions')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data?.docs ?? [];

          int makeupPending = 0;
          final Set<String> batches = {};

          for (final doc in sessions) {
            final data = doc.data() as Map<String, dynamic>;
            final makeup = data['makeup']?.toString() ?? 'Not scheduled';
            final batch = data['batch']?.toString() ?? '';

            if (makeup == 'Not scheduled') makeupPending++;
            if (batch.isNotEmpty) batches.add(batch);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _topHeader(context),
                _heroBanner(
                  total: sessions.length,
                  makeupPending: makeupPending,
                  batches: batches.length,
                ),

                const SizedBox(height: 18),

                _sectionTitle("CANCEL SESSION FORM"),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _warningBox(),
                      const SizedBox(height: 14),
                      _inputBox("Select Batch", batchController, Icons.groups),
                      _inputBox(
                        "Session Date",
                        dateController,
                        Icons.calendar_month,
                      ),
                      _inputBox(
                        "Session Time",
                        timeController,
                        Icons.access_time,
                      ),
                      _inputBox(
                        "Reason",
                        reasonController,
                        Icons.warning_amber,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: maroon,
                            foregroundColor: gold,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => _cancelSession(
                            context: context,
                            batchController: batchController,
                            dateController: dateController,
                            timeController: timeController,
                            reasonController: reasonController,
                          ),
                          icon: const Icon(Icons.notifications_active),
                          label: const Text(
                            "CANCEL & CREATE MAKEUP",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _sectionTitle("SESSION OVERVIEW"),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.15,
                    children: [
                      _smallStatCard(
                        Icons.event_busy,
                        "TOTAL",
                        sessions.length.toString(),
                        Colors.red,
                      ),
                      _smallStatCard(
                        Icons.groups,
                        "BATCHES",
                        batches.length.toString(),
                        Colors.blue,
                      ),
                      _smallStatCard(
                        Icons.event_repeat,
                        "MAKEUP",
                        makeupPending.toString(),
                        Colors.orange,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                _sectionTitle("RECENTLY CANCELLED"),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: sessions.isEmpty
                      ? _emptyCard()
                      : Column(
                          children: sessions.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            return _cancelledCard(
                              batch: data['batch']?.toString() ?? '',
                              date: data['date']?.toString() ?? '',
                              time: data['time']?.toString() ?? '',
                              reason: data['reason']?.toString() ?? '',
                              makeup:
                                  data['makeup']?.toString() ?? 'Not scheduled',
                            );
                          }).toList(),
                        ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _topHeader(BuildContext context) {
    return Container(
      color: maroon,
      padding: const EdgeInsets.fromLTRB(16, 45, 16, 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Image.asset('assets/images/ygca_logo.jpg', width: 58),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "CANCEL SESSION",
              style: TextStyle(
                color: gold,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.event_busy, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _heroBanner({
    required int total,
    required int makeupPending,
    required int batches,
  }) {
    return Container(
      height: 210,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        border: Border.all(color: gold, width: 1),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_hero_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    darkMaroon.withOpacity(0.96),
                    maroon.withOpacity(0.70),
                    Colors.black.withOpacity(0.38),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.event_busy, color: maroon, size: 42),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ACADEMY",
                        style: TextStyle(
                          color: gold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "SESSION",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      Text(
                        "CONTROL",
                        style: TextStyle(
                          color: gold,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _heroChip("Cancelled: $total"),
                          _heroChip("Batches: $batches"),
                          _heroChip("Makeup Pending: $makeupPending"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.7)),
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

  Widget _warningBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        border: Border.all(color: const Color(0xFFFECACA)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Cancel a session only when required. Parents and students will be notified immediately. A makeup session will be created automatically.",
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBox(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: maroon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: border),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: maroon,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Container(
          width: 35,
          height: 2,
          color: gold,
        ),
      ],
    ),
  );
}

  Widget _smallStatCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cancelledCard({
    required String batch,
    required String date,
    required String time,
    required String reason,
    required String makeup,
  }) {
    final needsMakeup = makeup == "Not scheduled";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFFEF2F2),
            child: Icon(Icons.event_busy, color: Colors.red.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch.isEmpty ? "Unknown Batch" : batch,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time.isEmpty ? date : "$date • $time",
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                _detailChip(Icons.warning_amber, reason, Colors.red),
                const SizedBox(height: 6),
                _detailChip(
                  Icons.event_repeat,
                  makeup,
                  needsMakeup ? Colors.orange : Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text.isEmpty ? "Not added" : text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_busy, size: 40, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No Cancelled Sessions Found",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text("Cancelled sessions will appear here"),
        ],
      ),
    );
  }
}