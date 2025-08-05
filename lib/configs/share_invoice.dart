import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_saver/file_saver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

Future<void> shareInvoice({
  required String invoiceId,
  required dynamic date,
  required List items,
  required dynamic totalItems,
  required dynamic totalQuantity,
  required dynamic subTotal,
  required dynamic total,
  required dynamic discountAmount,
  required dynamic advance,
  required dynamic due,
  required dynamic paid,
  String? mobile,
  String? address,
  String? name,
  List? payList,
  bool isSave = false,
}) async {
  // Load logo image
  final ByteData logoData = await rootBundle.load('assets/invoice_logo.png');
  final Uint8List logoBytes = logoData.buffer.asUint8List();
  final pdfLogo = pw.MemoryImage(logoBytes);

  // Generate PDF
  final pdf = await _generateInvoicePdf(
    invoiceId: invoiceId,
    date: date,
    items: items,
    totalItems: totalItems,
    totalQuantity: totalQuantity,
    subTotal: subTotal,
    total: total,
    discountAmount: discountAmount,
    advance: advance,
    due: due,
    paid: paid,
    mobile: mobile,
    address: address,
    name: name,
    payList: payList,
    logo: pdfLogo,
    showPaidWatermark: paid == subTotal, // Show watermark if paid
  );

  // Save or share
  if (isSave) {
    await FileSaver.instance.saveFile(
      name: '$invoiceId invoice.pdf',
      bytes: await pdf.save(),
      mimeType: MimeType.pdf,
    );
  } else {
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Viraeshop_$invoiceId.pdf',
    );
  }
}

Future<pw.Document> _generateInvoicePdf({
  required String invoiceId,
  required dynamic date,
  required List items,
  required dynamic totalItems,
  required dynamic totalQuantity,
  required dynamic subTotal,
  required dynamic total,
  required dynamic discountAmount,
  required dynamic advance,
  required dynamic due,
  required dynamic paid,
  required pw.MemoryImage logo,
  bool showPaidWatermark = false,
  String? mobile,
  String? address,
  String? name,
  List? payList,
}) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        // margin: const pw.EdgeInsets.symmetric(
        //   horizontal: 1.5 * PdfPageFormat.cm, // Equal left/right margins
        //   vertical: 1.5 * PdfPageFormat.cm, // Equal top/bottom margins
        // ),
        buildBackground: (context) {
          if (showPaidWatermark) {
            return pw.Watermark(
              angle: 45, // Degrees (converted to radians internally)
              child: pw.Opacity(
                opacity: 0.1,
                child: pw.Text(
                  'PAID',
                  style: pw.TextStyle(
                    fontSize: 100,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                ),
              ),
            );
          }
          return pw.Container(); // Empty when no watermark
        },
      ),
      build: (context) {
        return [
          pw.Container(
            alignment: pw.Alignment.center,
            child: pw.ConstrainedBox(
              constraints: const pw.BoxConstraints(
                maxWidth: 16 * PdfPageFormat.cm,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header with Logo
                  pw.Container(
                    width: 1100,
                    height: 200,
                    child: pw.Image(logo),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('H-65, New Airport, Amtoli, Mohakhali',
                              style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Dhaka-1212, Bangladesh',
                              style: const pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(height: 8),
                          pw.Text(
                              'Tel: 01710735425 | 01324430921 | 01324430922-30',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.Text('Email: viraeshop@gmail.com',
                              style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  // Invoice Info
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('INVOICE #$invoiceId',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Date: ${_formatDate(date)}'),
                    ],
                  ),
                  pw.Divider(thickness: 1),
                  pw.SizedBox(height: 10),
                  // Customer Info
                  if (name != null || mobile != null || address != null) ...[
                    pw.Text('Customer: ${name ?? '-'}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    if (address != null) pw.Text('Address: $address'),
                    if (mobile != null) pw.Text('Phone: $mobile'),
                    pw.SizedBox(height: 10),
                  ],

                  // Items Summary
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Qty: ${totalQuantity.toString()}'),
                      pw.Text('${totalItems.toString()} Items',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.SizedBox(height: 10),

                  // Product Table
                  pw.Table(
                    border: pw.TableBorder.all(
                        color: PdfColors.grey300, width: 0.5),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(1.5),
                      2: const pw.FlexColumnWidth(1.5),
                      3: const pw.FlexColumnWidth(1.5),
                    },
                    children: [
                      // Header Row
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Product',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Qty',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Unit Price',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Amount',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ],
                      ),
                      // Product Rows
                      ...items.map((item) => pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Column(
                                  crossAxisAlignment:
                                  pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      item['productName'].toString(),
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.Text(
                                      item['productCode'].toString(),
                                      style: const pw.TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text('${item['quantity']} x',
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  _formatCurrency(
                                    item['unitPrice'],
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  _formatCurrency(
                                    item['productPrice'],
                                  ),
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                  pw.SizedBox(height: 20),

                  // Payment Summary
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Container(
                      width: 250,
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        children: [
                          _buildSummaryRow('VAT%', _formatCurrency(0)),
                          _buildSummaryRow('Total', _formatCurrency(total)),
                          _buildSummaryRow(
                              'Discount', _formatCurrency(discountAmount)),
                          _buildSummaryRow(
                              'Sub Total', _formatCurrency(subTotal)),
                          if (advance != '0')
                            _buildSummaryRow(
                                'Advance', _formatCurrency(advance)),
                          if (payList != null && payList.isNotEmpty) ...[
                            pw.SizedBox(height: 8),
                            pw.Text('Payment History:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            ...payList
                                .map((payment) => pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(
                                          vertical: 2),
                                      child: pw.Row(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Text(
                                              _formatDate(payment['createdAt']),
                                              style: const pw.TextStyle(
                                                  fontSize: 9)),
                                          pw.Text(
                                              _formatCurrency(payment['paid']),
                                              style: const pw.TextStyle(
                                                  fontSize: 9)),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            pw.SizedBox(height: 8),
                          ],
                          _buildSummaryRow('Paid', _formatCurrency(paid)),
                          pw.Divider(thickness: 0.5),
                          _buildSummaryRow('TOTAL DUE', _formatCurrency(due),
                              isTotal: true),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Footer
                  pw.Center(
                    child: pw.Text('Thank you for your business!',
                        style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
                  ),
                ],
              ),
            ),
          ),
        ];
      },
    ),
  );

  return pdf;
}

// Helper functions remain the same as previous version
String _formatCurrency(dynamic value) {
  if (value == null) return 'BDT 0.00';
  final number =
      value is String ? double.tryParse(value) ?? 0 : value.toDouble();
  return 'BDT ${NumberFormat('#,##0.00').format(number)}';
}

String _formatDate(dynamic date) {
  try {
    if (date is String) {
      // Parse ISO 8601 string to DateTime and format it
      final parsedDate = DateTime.tryParse(date);
      if (parsedDate != null) {
        return DateFormat('dd/MM/yyyy').format(parsedDate);
      }
      return date; // Return the original string if parsing fails
    }
    if (date is DateTime) {
      return DateFormat('dd/MM/yyyy').format(date);
    }
    if (date is Timestamp) {
      return DateFormat('dd/MM/yyyy').format(date.toDate());
    }
    return date.toString();
  } catch (e) {
    return date.toString();
  }
}

pw.Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label),
        pw.Text(value,
            style: isTotal
                ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)
                : null),
      ],
    ),
  );
}
