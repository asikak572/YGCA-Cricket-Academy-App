import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class ExcelService {
  static Future<void> generateFeeReportExcel({
    required List<Map<String, dynamic>> feeRecords,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Fee Report'];

    sheet.appendRow([
      TextCellValue('Student Name'),
      TextCellValue('Student ID'),
      TextCellValue('Total Fee'),
      TextCellValue('Paid Amount'),
      TextCellValue('Pending Amount'),
      TextCellValue('Status'),
    ]);

    for (final data in feeRecords) {
      sheet.appendRow([
        TextCellValue(data['studentName']?.toString() ?? 'Unknown'),
        TextCellValue(data['studentId']?.toString() ?? ''),
        TextCellValue(data['totalFee']?.toString() ?? '0'),
        TextCellValue(data['paidAmount']?.toString() ?? '0'),
        TextCellValue(data['pendingAmount']?.toString() ?? '0'),
        TextCellValue(data['status']?.toString() ?? 'Pending'),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/ygca_fee_report.xlsx');

    await file.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(file.path);
  }
}