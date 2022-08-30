import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:async';
//import 'dart:js' as js;
import 'package:flutter/services.dart' show rootBundle;

/// generate transaction statement
Future<void> generateCustomerStatement({
  required List items,
  mobile,
  address,
  name,
  email,
  totalAmount,
  totalDue,
  totalPay,
  totalSale,  
  required bool isInventory,
  required DateTime begin,
  end,
}) async {
  //Create a new PDF document
  String invoiceId = randomNumeric(3);
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

  /// Logo
  page.graphics.drawImage(PdfBitmap(imageBytes),
      Rect.fromLTWH(graphics.clientSize.width - 100, 15, 100, 100));

  /// Customer name
  PdfTextElement element = PdfTextElement(
    text: name ?? '',
    font: PdfStandardFont(
      PdfFontFamily.timesRoman,
      16,
      style: PdfFontStyle.bold,
    ),
  );
  element.brush = brushColor;
  PdfLayoutResult result = element.draw(
    page: page,
    bounds: const Rect.fromLTWH(10, 115, 0, 0),
  )!;
    /// customer mobile    
    element = PdfTextElement(
      text: mobile,
      font: timesRoman,
    );
    element.brush = brushColor;
    result = element.draw(
      page: page,
      bounds: const Rect.fromLTWH(10, 130, 0, 0),
    )!;

    /// customer email    
    element = PdfTextElement(
      text: email,
      font: timesRoman,
    );
    element.brush = brushColor;
    result = element.draw(
      page: page,
      bounds: const Rect.fromLTWH(10, 145, 0, 0),
    )!;

    /// customer address
    element = PdfTextElement(text: address, font: timesRoman);
    element.brush = brushColor;
    result = element.draw(
      page: page,
      bounds: const Rect.fromLTWH(10, 160, 0, 0),
    )!;

  /// designation
  element = PdfTextElement(text: 'Total Sales', font: PdfStandardFont(PdfFontFamily.timesRoman, 16,
      style: PdfFontStyle.bold,),);
  element.brush = brushColor;
  result = element.draw(page: page, bounds: const Rect.fromLTWH(10, 180, 0, 0))!;

  /// Dates
  String beginDate = DateFormat.yMMMd().format(begin);
  String endDate = DateFormat.yMMMd().format(end);
  // Measures the width of the text to place it in the correct location
  Size beginSize = timesRoman.measureString(beginDate);

  /// draw date
  element = PdfTextElement(text: beginDate, font: timesRoman);
  element.brush = brushColor;
  result = element.draw(page: page, bounds: const Rect.fromLTWH(10, 200, 0, 0))!;

  /// to
  element = PdfTextElement(text: 'TO', font: timesRoman);
  element.brush = brushColor;
  result = element.draw(
      page: page, bounds: Rect.fromLTWH(beginSize.width + 20, 200, 0, 0),)!;

  /// end date
  element = PdfTextElement(text: endDate, font: timesRoman);
  element.brush = brushColor;
  result = element.draw(
    page: page,
    bounds: Rect.fromLTWH(beginSize.width + 50, 200, 0, 0),
  )!;

  /// Horizontal Line
  // graphics.drawLine(
  //     PdfPen(color, width: 1),
  //     Offset(0, result.bounds.bottom + 10),
  //     Offset(graphics.clientSize.width, result.bounds.bottom + 10));
  grid.columns.add(count: 5);
  PdfGridRow headerRow = grid.rows.add();
  headerRow.cells[0].value = 'SL';
  headerRow.cells[1].value = 'Invoice No';
  headerRow.cells[2].value = 'Paid';
  headerRow.cells[3].value = 'Due';
  headerRow.cells[4].value = 'Amount';
  for (int i = 0; i < items.length; i++) {
    int index = i + 1;
    PdfGridRow row = grid.rows.add();
    row.cells[0].value =
        index >= 10 ? '${index.toString()}' : '0${index.toString()}';
    row.cells[1].value = '${items[i]!['invoice_id']}';
    row.cells[2].value = '${items[i]!['paid']}';
    row.cells[3].value = '${items[i]!['due']}';
    row.cells[4].value = '${items[i]!['price']}';
  }
  //Set padding for grid cells
  grid.style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);
  PdfLayoutFormat layoutFormat =
      PdfLayoutFormat(layoutType: PdfLayoutType.paginate);
//Creates the grid cell styles
  PdfGridCellStyle cellStyle = PdfGridCellStyle();
  cellStyle.borders.all = PdfPens.white;
  cellStyle.borders.bottom = PdfPen(PdfColor(23,23,23));
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
    bounds: Rect.fromLTWH(20, 250, graphics.clientSize.width - 60,
        graphics.clientSize.height - 100),
    format: layoutFormat,
  )!;
  // vat
  String totalPays = 'Total Pay $totalPay';
  Size vatSize = timesRoman.measureString(totalPays);
  gridResult.page.graphics.drawString(
    totalPays,
    timesRoman,
    brush: PdfSolidBrush(color),
    bounds: Rect.fromLTWH(graphics.clientSize.width - vatSize.width,
        gridResult.bounds.bottom + 30, 0, 0),
  );

  ///to add Discount
  String totalDues = 'Total Due $totalDue';
  Size textSize1 = timesRoman.measureString(totalDues);
  gridResult.page.graphics.drawString(totalDues, timesRoman,
      brush: PdfBrushes.darkRed,
      bounds: Rect.fromLTWH(graphics.clientSize.width - textSize1.width,
          gridResult.bounds.bottom + 50, 0, 0));
  // sub total
  String totalAmounts = 'Total Amount $totalAmount BDT';
  Size subTotalSize = timesRoman.measureString(totalAmounts);
  gridResult.page.graphics.drawString(totalAmounts, timesRoman,
      brush: PdfSolidBrush(color),
      bounds: Rect.fromLTWH(graphics.clientSize.width - subTotalSize.width,
          gridResult.bounds.bottom + 70, 0, 0),);
  // total sales
  if(isInventory){
     String totalSales = 'Total Sales $totalSale BDT';
  Size totalSaleSize = timesRoman.measureString(totalSales);
  gridResult.page.graphics.drawString(totalSales, timesRoman,
      brush: PdfSolidBrush(color),
      bounds: Rect.fromLTWH(graphics.clientSize.width - totalSaleSize.width,
          gridResult.bounds.bottom + 90, 0, 0),);
  }
  //Save the document
  List<int> bytes = document.save();
  //Dispose the document
  //js.context['pdfData'] = base64.encode(bytes);
  //js.context['filename'] = 'Invoice_$invoiceId.pdf';
  //Timer.run(() {
  //  js.context.callMethod('download');
  //});
  document.dispose();
}
