import 'package:flutter/material.dart';

import '../core/language/app_strings.dart';
import '../theme/theme_controller.dart';
import 'widgets/ygca_app_bar.dart';

class FeePaymentScreen extends StatelessWidget {
  const FeePaymentScreen({super.key});

  static const Color maroon = Color(0xFF7F0000);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bg = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: ThemeController.language,
      builder: (context, language, _) {
        return Scaffold(
          backgroundColor: bg,
          appBar: YgcaAppBar(
            title: AppStrings.feePaymentTitle,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _summaryCard(),
                const SizedBox(height: 16),
                _paymentMethod(
                  AppStrings.upiPayment,
                  Icons.qr_code,
                ),
                _paymentMethod(
                  AppStrings.cashPayment,
                  Icons.money,
                ),
                _paymentMethod(
                  AppStrings.bankTransfer,
                  Icons.account_balance,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroon,
                      foregroundColor: gold,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppStrings.paymentRecordedSuccessfully,
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: Text(
                      AppStrings.payNow,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            "Arjun R",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${AppStrings.totalFee}: ₹12,000",
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          Text(
            "${AppStrings.paid}: ₹8,000",
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          Text(
            "${AppStrings.pending}: ₹4,000",
            style: const TextStyle(
              color: gold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethod(String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: maroon,
          child: Icon(
            icon,
            color: gold,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
      ),
    );
  }
}