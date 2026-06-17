import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunicationCenterScreen extends StatefulWidget {
  const CommunicationCenterScreen({super.key});

  @override
  State<CommunicationCenterScreen> createState() =>
      _CommunicationCenterScreenState();
}

class _CommunicationCenterScreenState extends State<CommunicationCenterScreen> {
  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  final titleController = TextEditingController();
  final messageController = TextEditingController();

  String selectedType = "Academy Announcement";
  String selectedTarget = "All";
  String selectedBatch = "All";
  bool isSending = false;

  final List<String> messageTypes = [
    "Academy Announcement",
    "Match Schedule",
    "Practice Cancelled",
    "Tournament Update",
    "Camp Registration",
    "Custom Message",
  ];

  final List<String> targetOptions = [
    "All",
    "Students",
    "Parents",
    "Coaches",
    "Batch Wise",
  ];

  final List<String> batchOptions = [
    "All",
    "U-14",
    "U-15",
    "U-16",
    "Senior batch",
  ];

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> _sendCommunication() async {
    if (titleController.text.trim().isEmpty ||
        messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill title and message")),
      );
      return;
    }

    setState(() => isSending = true);

    try {
      await FirebaseFirestore.instance.collection('communication_logs').add({
        'title': titleController.text.trim(),
        'message': messageController.text.trim(),
        'type': selectedType,
        'target': selectedTarget,
        'batch': selectedBatch,
        'sentBy': FirebaseAuth.instance.currentUser?.uid ?? '',
        'status': 'Pending API Integration',
        'channels': ['In-App', 'SMS', 'WhatsApp'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('notifications').add({
        'title': titleController.text.trim(),
        'message': messageController.text.trim(),
        'targetRole': selectedTarget == "Students"
            ? "Student"
            : selectedTarget == "Parents"
                ? "Parent"
                : selectedTarget == "Coaches"
                    ? "Coach"
                    : "All",
        'createdBy': FirebaseAuth.instance.currentUser?.uid ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      titleController.clear();
      messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Communication saved. SMS/WhatsApp API will be connected later.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    } finally {
      if (mounted) setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Communication Center"),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _heroCard(),
            const SizedBox(height: 16),
            _formCard(),
            const SizedBox(height: 16),
            _infoCard(),
          ],
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.campaign, color: gold, size: 48),
          const SizedBox(height: 8),
          Text(
            "YGCA Communication Center",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: gold,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Send announcements, match updates and academy alerts",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _formCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _dropdown(
            label: "Message Type",
            value: selectedType,
            items: messageTypes,
            onChanged: (value) {
              if (value == null) return;
              setState(() => selectedType = value);
            },
          ),
          const SizedBox(height: 10),
          _dropdown(
            label: "Target Audience",
            value: selectedTarget,
            items: targetOptions,
            onChanged: (value) {
              if (value == null) return;
              setState(() => selectedTarget = value);
            },
          ),
          if (selectedTarget == "Batch Wise") ...[
            const SizedBox(height: 10),
            _dropdown(
              label: "Select Batch",
              value: selectedBatch,
              items: batchOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() => selectedBatch = value);
              },
            ),
          ],
          const SizedBox(height: 10),
          _inputField("Title", titleController),
          const SizedBox(height: 10),
          _inputField("Message", messageController, maxLines: 4),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: maroon,
                foregroundColor: gold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: isSending ? null : _sendCommunication,
              icon: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(
                isSending ? "SENDING..." : "SEND COMMUNICATION",
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        border: Border.all(color: const Color(0xFFFDE68A)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Currently this saves communication logs and creates in-app notifications. Real SMS/WhatsApp API integration will be connected later.",
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}