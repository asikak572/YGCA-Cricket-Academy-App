import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateFeeReportPdf({
    required int totalFee,
    required int collected,
    required int pending,
    required int paidStudents,
    required List<Map<String, dynamic>> feeRecords,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Center(
            child: pw.Text(
              "YGCA Fee Report",
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 20),

          pw.Text("Total Fee: Rs.$totalFee"),
          pw.Text("Collected: Rs.$collected"),
          pw.Text("Pending: Rs.$pending"),
          pw.Text("Paid Records: $paidStudents"),

          pw.SizedBox(height: 20),

          pw.Text(
            "Student Fee Records",
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),

          pw.Table.fromTextArray(
            headers: [
              "Student",
              "ID",
              "Total",
              "Paid",
              "Pending",
              "Status",
            ],
            data: feeRecords.map((data) {
              return [
                data['studentName']?.toString() ?? 'Unknown',
                data['studentId']?.toString() ?? '',
                "Rs.${data['totalFee'] ?? 0}",
                "Rs.${data['paidAmount'] ?? 0}",
                "Rs.${data['pendingAmount'] ?? 0}",
                data['status']?.toString() ?? 'Pending',
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}