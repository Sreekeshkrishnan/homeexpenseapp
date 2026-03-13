import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {

  static Future<pw.Document> generateReport({
    required String period,
    required double income,
    required double expense,
    required double balance,
    required String title,
  }) async {

    final pdf = pw.Document();

    /// ✅ Load Unicode Font (₹ support)
    final font = pw.Font.ttf(
      await rootBundle.load(
        "assets/fonts/NotoSans-Regular.ttf",
      ),
    );

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(30),
        build: (context) {

          return pw.DefaultTextStyle(
            style: pw.TextStyle(font: font),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                /// HEADER
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blueGrey900,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Row(
                    mainAxisAlignment:
                    pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        "Expense Analytics Report",
                        style: pw.TextStyle(
                          font: font,
                          color: PdfColors.white,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        period.toUpperCase(),
                        style: pw.TextStyle(
                          font: font,
                          color: PdfColors.greenAccent,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 25),

                /// SUMMARY CARDS
                pw.Row(
                  mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _summaryBox("Income", income, PdfColors.green, font),
                    _summaryBox("Expense", expense, PdfColors.red, font),
                    _summaryBox("Balance", balance, PdfColors.purple, font),
                  ],
                ),

                pw.SizedBox(height: 40),

                pw.Divider(),

                pw.SizedBox(height: 10),

                pw.Text(
                  "Financial Summary",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 15),

                pw.Bullet(
                  text:
                  "Total Income for $period : ₹${income.toStringAsFixed(2)}",
                  style: pw.TextStyle(font: font),
                ),

                pw.Bullet(
                  text:
                  "Total Expense for $period : ₹${expense.toStringAsFixed(2)}",
                  style: pw.TextStyle(font: font),
                ),

                pw.Bullet(
                  text:
                  "Remaining Balance : ₹${balance.toStringAsFixed(2)}",
                  style: pw.TextStyle(font: font),
                ),

                pw.Spacer(),

                pw.Center(
                  child: pw.Text(
                    "Generated from Home Expense App",
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      color: PdfColors.grey,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  /// SUMMARY BOX
  static pw.Widget _summaryBox(
      String title,
      double amount,
      PdfColor color,
      pw.Font font) {

    return pw.Container(
      width: 160,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: color, width: 2),
      ),
      child: pw.Column(
        children: [
          pw.Text(title,
              style: pw.TextStyle(font: font, color: color)),
          pw.SizedBox(height: 6),
          pw.Text(
            "₹ ${amount.toStringAsFixed(0)}",
            style: pw.TextStyle(
              font: font,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}