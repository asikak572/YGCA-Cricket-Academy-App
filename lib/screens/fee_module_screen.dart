import 'package:flutter/material.dart';

import 'widgets/ygca_app_bar.dart';

import 'fee_management_screen.dart';
import 'payment_history_screen.dart';
import 'pending_fees_screen.dart';
import 'fee_report_screen.dart';

class FeeModuleScreen extends StatelessWidget {
  FeeModuleScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8F9FC);
  final Color border = const Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: const YgcaAppBar(title: "Fee Module"),
      body: Column(
        children: [
          _header(),
          const SizedBox(height: 16),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.05,
                children: [

                  _moduleCard(
                    context,
                    Icons.payments,
                    "Collect Fee",
                    Colors.green,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FeeManagementScreen(),
                        ),
                      );
                    },
                  ),

                  _moduleCard(
                    context,
                    Icons.receipt,
                    "Payment History",
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaymentHistoryScreen(),
                        ),
                      );
                    },
                  ),

                  _moduleCard(
                    context,
                    Icons.warning_amber,
                    "Pending Fees",
                    Colors.orange,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PendingFeesScreen(),
                        ),
                      );
                    },
                  ),

                  _moduleCard(
                    context,
                    Icons.analytics,
                    "Fee Reports",
                    Colors.purple,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FeeReportScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: maroon,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.currency_rupee,
            color: gold,
            size: 50,
          ),

          const SizedBox(height: 8),

          const Text(
            "FEE MANAGEMENT",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            "Collect payments, track pending fees and reports",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _moduleCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: color,
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 25,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}