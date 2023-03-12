import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:random_string/random_string.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:async';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<void> shareInvoice({
  required String totalItems,
  totalPrice,
  discountAmount,
  required subTotal,
  required List items,
  required String mobile,
  required String date,
  List payList = const [],
  bool isSave = false,
  address,
  name,
  advance,
  due,
  paid,
  totalQuantity,
  invoiceId,
}) async {
  //Create a new PDF document
  Uint8List imageBytes =
      (await rootBundle.load('assets/images/DONE.png')).buffer.asUint8List();
  PdfDocument document = PdfDocument();
  document.pageSettings.orientation = PdfPageOrientation.portrait;
  document.pageSettings.size = PdfPageSize.a4;
  document.pageSettings.margins.all = 50;
  PdfPage page = document.pages.add();
  PdfGraphics graphics = page.graphics;
  PdfSolidBrush brushColor = PdfSolidBrush(PdfColor(55, 63, 74));
  PdfColor color = PdfColor(55, 63, 74);
  PdfGrid grid = PdfGrid();
  PdfFont timesRoman = PdfStandardFont(PdfFontFamily.timesRoman, 14,
      style: PdfFontStyle.regular);
  Size textSize = timesRoman.measureString('Invoice No. $invoiceId');

  /// Logo
  page.graphics
      .drawImage(PdfBitmap(imageBytes), const Rect.fromLTWH(0, 15, 100, 100));

  /// Mobile no.
  PdfTextElement element =
      PdfTextElement(text: 'Tel: 01710735425 01715041368', font: timesRoman);
  element.brush = brushColor;
  PdfLayoutResult result =
      element.draw(page: page, bounds: const Rect.fromLTWH(10, 120, 0, 0))!;

  /// email address
  element =
      PdfTextElement(text: 'Email: viraeshop@gmail.com', font: timesRoman);
  element.brush = brushColor;
  result =
      element.draw(page: page, bounds: const Rect.fromLTWH(10, 135, 0, 0))!;

  /// Address
  element = PdfTextElement(
      text: 'H-65, New Airport, Amtoli, Mohakhali,', font: timesRoman);
  element.brush = brushColor;
  result =
      element.draw(page: page, bounds: const Rect.fromLTWH(10, 155, 0, 0))!;
  element = PdfTextElement(text: 'Dhaka-1212, Bangladesh.', font: timesRoman);
  element.brush = brushColor;
  result = element.draw(
    page: page,
    bounds: const Rect.fromLTWH(10, 170, 0, 0),
  )!;

  /// date
  String currentDate = 'Date: $date';
  // Measures the width of the text to place it in the correct location
  Size size = timesRoman.measureString(currentDate);
  element = PdfTextElement(text: currentDate, font: timesRoman);
  element.brush = brushColor;
  result = element.draw(
      page: page,
      bounds:
          Rect.fromLTWH(graphics.clientSize.width - size.width, 175, 0, 0))!;

  /// Invoice Number
  element = PdfTextElement(text: 'Invoice No. $invoiceId', font: timesRoman);
  element.brush = brushColor;
  result = element.draw(
    page: page,
    bounds:
        Rect.fromLTWH(graphics.clientSize.width - textSize.width, 195, 0, 0),
  )!;

  /// Customer name
  element = PdfTextElement(
    text: name,
    font: PdfStandardFont(
      PdfFontFamily.timesRoman,
      16,
      style: PdfFontStyle.bold,
    ),
  );
  element.brush = brushColor;
  result = element.draw(
    page: page,
    bounds: const Rect.fromLTWH(10, 195, 0, 0),
  )!;

  /// customer mobile
  element = PdfTextElement(
    text: mobile,
    font: timesRoman,
  );
  element.brush = brushColor;
  result = element.draw(
    page: page,
    bounds: const Rect.fromLTWH(10, 215, 0, 0),
  )!;

  /// customer address
  element = PdfTextElement(text: address, font: timesRoman);
  element.brush = brushColor;
  result = element.draw(
    page: page,
    bounds: const Rect.fromLTWH(10, 230, 0, 0),
  )!;

  /// items
  element = PdfTextElement(
      text: '$totalItems Items (QTY $totalQuantity)', font: timesRoman);
  element.brush = PdfSolidBrush(PdfColor(12, 187, 139));
  result =
      element.draw(page: page, bounds: const Rect.fromLTWH(10, 250, 0, 0))!;

  /// Horizontal Line
  // graphics.drawLine(
  //     PdfPen(color, width: 1),
  //     Offset(0, result.bounds.bottom + 10),
  //     Offset(graphics.clientSize.width, result.bounds.bottom + 10));
  grid.columns.add(count: 4);
  PdfGridRow headerRow = grid.rows.add();
  headerRow.cells[0].value = 'Quantity';
  headerRow.cells[1].value = 'Name';
  headerRow.cells[2].value = 'Price(BDT)';
  headerRow.cells[3].value = 'Amount(BDT)';
  for (var element in items) {
    PdfGridRow row = grid.rows.add();
    row.cells[0].value = '${element['quantity']} X';
    row.cells[1].value = '${element['productName']}(${element['productId']})';
    row.cells[2].value = '${element['unitPrice']}';
    row.cells[3].value = '${element['productPrice']}';
  }
  //Set padding for grid cells
  grid.style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);
  PdfLayoutFormat layoutFormat =
      PdfLayoutFormat(layoutType: PdfLayoutType.paginate);
//Creates the grid cell styles
  PdfGridCellStyle cellStyle = PdfGridCellStyle();
  cellStyle.borders.all = PdfPens.white;
  cellStyle.borders.bottom = PdfPens.white;
  cellStyle.font = PdfStandardFont(PdfFontFamily.timesRoman, 14);
  cellStyle.textBrush = PdfSolidBrush(color);
//Adds cell customizations
  for (int i = 0; i < grid.rows.count; i++) {
    PdfGridRow row = grid.rows[i];
    for (int j = 0; j < row.cells.count; j++) {
      row.cells[j].style = cellStyle;
      if (j == 0 || j == 1) {
        row.cells[j].stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.left,
            lineAlignment: PdfVerticalAlignment.middle);
      } else {
        row.cells[j].stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle);
      }
    }
  }
//Draws the grid to the PDF page
  PdfLayoutResult gridResult = grid.draw(
    page: page,
    bounds: Rect.fromLTWH(20, 270, graphics.clientSize.width - 60,
        graphics.clientSize.height - 100),
    format: layoutFormat,
  )!;
  // vat
  String vat = 'VAT %';
  Size vatSize = timesRoman.measureString(vat);
  PdfTextElement(
    text: vat,
    font: timesRoman,
    brush: PdfSolidBrush(color),
  ).draw(
    format: layoutFormat,
    page: gridResult.page,
    bounds: Rect.fromLTWH(
      graphics.clientSize.width - vatSize.width,
      gridResult.bounds.bottom + 30,
      0,
      0,
    ),
  );

  ///to add Discount
  Size textSize1 = timesRoman.measureString('Discount $discountAmount BDT');
  PdfTextElement(
    text: 'Discount $discountAmount BDT',
    font: timesRoman,
    brush: PdfSolidBrush(PdfColor(215, 44, 67)),
  ).draw(
      format: layoutFormat,
      page: gridResult.page,
      bounds: Rect.fromLTWH(graphics.clientSize.width - textSize1.width,
          gridResult.bounds.bottom + 50, 0, 0));
  // sub total
  String subTotals = 'Sub Total $subTotal  BDT';
  Size subTotalSize = timesRoman.measureString(subTotals);
  PdfTextElement(
    text: subTotals,
    font: timesRoman,
    brush: PdfSolidBrush(color),
  ).draw(
    format: layoutFormat,
    page: gridResult.page,
    bounds: Rect.fromLTWH(
      graphics.clientSize.width - subTotalSize.width,
      gridResult.bounds.bottom + 70,
      0,
      0,
    ),
  );

  /// advance
  String advanceText = 'Advance $advance BDT';
  Size textSize2 = timesRoman.measureString(advanceText);
  PdfTextElement(
    text: advanceText,
    font: timesRoman,
    brush: PdfSolidBrush(color),
  ).draw(
    format: layoutFormat,
    page: gridResult.page,
    bounds: Rect.fromLTWH(
      graphics.clientSize.width - textSize2.width,
      gridResult.bounds.bottom + 90,
      0,
      0,
    ),
  );

  ///pay list
  int spacing = 110;
  for (var element in payList) {
    Timestamp timestamp = element['date'];
    final formatter = DateFormat('MM/dd/yyyy');
    String dateTime = formatter.format(
      timestamp.toDate(),
    );
    String paidText = '$dateTime  Pay ${element['paid']}';
    Size dueSize = timesRoman.measureString(paidText);
    PdfTextElement(
      text: paidText,
      font: timesRoman,
      brush: PdfSolidBrush(color),
    ).draw(
      format: layoutFormat,
      page: gridResult.page,
      bounds: Rect.fromLTWH(
        graphics.clientSize.width - dueSize.width,
        gridResult.bounds.bottom + spacing,
        0,
        0,
      ),
    );
    spacing += 20;
  }

  /// Due
  String dueText = 'Due $due BDT';
  Size dueSize = timesRoman.measureString(dueText);
  PdfTextElement(
    text: dueText,
    font: timesRoman,
    brush: PdfSolidBrush(color),
  ).draw(
    format: layoutFormat,
    page: gridResult.page,
    bounds: Rect.fromLTWH(
      graphics.clientSize.width - dueSize.width,
      gridResult.bounds.bottom + spacing,
      0,
      0,
    ),
  );

  /// paid
  String paidText = 'Paid $paid BDT';
  Size paidSize = timesRoman.measureString(paidText);
  PdfTextElement(
    text: paidText,
    font: timesRoman,
    brush: PdfSolidBrush(color),
  ).draw(
      page: gridResult.page,
      format: layoutFormat,
      bounds: Rect.fromLTWH(graphics.clientSize.width - paidSize.width,
          gridResult.bounds.bottom + spacing + 20, 0, 0));

  /// total amount
  String amountText = 'Amount $subTotal BDT';
  Size amountSize = timesRoman.measureString(amountText);
  PdfTextElement(
    text: amountText,
    font: timesRoman,
    brush: PdfSolidBrush(color),
  ).draw(
    page: gridResult.page,
    format: layoutFormat,
    bounds: Rect.fromLTWH(graphics.clientSize.width - amountSize.width,
        gridResult.bounds.bottom + spacing + 40, 0, 0),
  );
  //Save the document
  List<int> bytes = document.save();
  if (isSave) {
    try {
      await FileSaver.instance.saveAs(
        'viraeshop_invoice$invoiceId.pdf',
        Uint8List.fromList(bytes),
        'PDF',
        MimeType.PDF,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  } else {
    await Printing.sharePdf(
        bytes: Uint8List.fromList(bytes),
        filename: 'viraeshop_invoice$invoiceId.pdf');
  }
  document.dispose();
}
