import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:random_string/random_string.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tuple/tuple.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:viraeshop_admin/reusable_widgets/transaction_functions/functions.dart';

/// share statement
Future<void> shareStatement({
  bool isWithAddress = true,
  bool isEmployee = false,
  required List items,
  Map<String, dynamic> data = const {},
  bool isSave = false,
  bool isPrint = false,
  name,
  businessName,
  totalAmount,
  totalDue,
  totalPay,
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
  PdfPageTemplateElement footer = PdfPageTemplateElement(
      Rect.fromLTWH(0, 0, document.pageSettings.size.width, 50));
  PdfSolidBrush brushColor = PdfSolidBrush(PdfColor(55, 63, 74));
  PdfColor color = PdfColor(55, 63, 74);
  PdfGrid grid = PdfGrid();
  PdfFont timesRoman =
      PdfStandardFont(PdfFontFamily.courier, 18, style: PdfFontStyle.regular);
  //Create the page number field
  PdfPageNumberField pageNumber = PdfPageNumberField(
    font: timesRoman,
    brush: PdfSolidBrush(
      PdfColor(53, 61, 77),
    ),
  );
  pageNumber.numberStyle = PdfNumberStyle.numeric;
  PdfPageCountField count = PdfPageCountField(
    font: timesRoman,
    brush: PdfSolidBrush(
      PdfColor(53, 61, 77),
    ),
  );

//set the number style for page count
  count.numberStyle = PdfNumberStyle.numeric;
  PdfCompositeField compositeField = PdfCompositeField(
      font: timesRoman,
      brush: PdfSolidBrush(
        PdfColor(53, 61, 77),
      ),
      text: 'Page {0} of {1}',
      fields: <PdfAutomaticField>[pageNumber, count]);
  compositeField.bounds = footer.bounds;

//Add the composite field in footer
  compositeField.draw(footer.graphics,
      Offset(290, 50 - PdfStandardFont(PdfFontFamily.timesRoman, 19).height));

//Add the footer at the bottom of the document
  document.template.bottom = footer;

  /// Logo
  page.graphics.drawImage(PdfBitmap(imageBytes),
      Rect.fromLTWH(graphics.clientSize.width - 100, 15, 100, 100));

  /// Customer name
  PdfTextElement element = PdfTextElement(
    text: name,
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

  /// Title
  element = PdfTextElement(
    text: 'Transaction Details',
    font: PdfStandardFont(
      PdfFontFamily.timesRoman,
      16,
      style: PdfFontStyle.bold,
    ),
  );
  element.brush = PdfSolidBrush(PdfColor(53, 61, 77));
  result =
      element.draw(page: page, bounds: const Rect.fromLTWH(10, 135, 0, 0))!;

  /// Dates
  String beginDate = DateFormat.yMMMd().format(begin);
  String endDate = DateFormat.yMMMd().format(end);
  // Measures the width of the text to place it in the correct location
  Size beginSize = timesRoman.measureString(beginDate);

  /// draw date
  element = PdfTextElement(text: beginDate, font: timesRoman);
  element.brush = PdfSolidBrush(PdfColor(19, 24, 68));
  result =
      element.draw(page: page, bounds: const Rect.fromLTWH(10, 155, 0, 0))!;

  /// to
  if (beginDate != endDate) {
    element = PdfTextElement(text: 'TO', font: timesRoman);
    element.brush = PdfSolidBrush(PdfColor(53, 61, 77));
    result = element.draw(
        page: page, bounds: Rect.fromLTWH(beginSize.width + 20, 155, 0, 0))!;

    /// end date
    element = PdfTextElement(text: endDate, font: timesRoman);
    element.brush = PdfSolidBrush(PdfColor(19, 24, 68));
    result = element.draw(
      page: page,
      bounds: Rect.fromLTWH(beginSize.width + 50, 155, 0, 0),
    )!;
  }

  /// Table
  grid.columns.add(count: 5);
  PdfGridRow headerRow = grid.rows.add();
  headerRow.style = PdfGridRowStyle(
    backgroundBrush: PdfSolidBrush(PdfColor(53, 61, 77)),
    textBrush: PdfSolidBrush(PdfColor(255, 255, 255)),
    textPen: PdfPens.white,
  );
  headerRow.cells[0].value = 'SL';
  headerRow.cells[1].value = 'Name';
  headerRow.cells[2].value = 'Paid';
  headerRow.cells[3].value = 'Due';
  headerRow.cells[4].value = 'Amount';
  int index = 0;
  for (var element in items) {
    ++index;
    PdfGridRow row = grid.rows.add();
    row.cells[0].value =
        index >= 10 ? index.toString() : '0${index.toString()}';
    row.cells[1].value = element['businessName'] != ''
        ? element['businessName']
        : element['name'];
    row.cells[2].value = '${element['totalPaid']}';
    row.cells[3].value = '${element['totalDue']}';
    row.cells[4].value = '${element['totalAmount']}';
  }
  // for (int i = 0; i < items.keys.length; i++) {
  //   int index = i + 1;
  // }
  //Set padding for grid cells
  grid.style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2, bottom: 2);
  PdfLayoutFormat layoutFormat =
      PdfLayoutFormat(layoutType: PdfLayoutType.paginate);
//Creates the grid cell styles
  PdfGridCellStyle cellStyle = PdfGridCellStyle();
  cellStyle.borders.all = PdfPens.white;
  cellStyle.borders.bottom = PdfPen(
    PdfColor(23, 23, 23),
  );
  cellStyle.font = PdfStandardFont(PdfFontFamily.courier, 12);
  cellStyle.textBrush = PdfSolidBrush(color);
//Adds cell customizations
  for (int i = 0; i < grid.rows.count; i++) {
    PdfGridRow row = grid.rows[i];
    if (i == 0) {
      for (int h = 0; h < row.cells.count; h++) {
        row.cells[h].style = PdfGridCellStyle(
          font: PdfStandardFont(PdfFontFamily.courier, 16),
          textBrush: PdfSolidBrush(PdfColor(255, 255, 255)),
          cellPadding: PdfPaddings(top: 5.0, bottom: 5.0),
        );
        row.cells[h].stringFormat = PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle,
        );
      }
    } else {
      for (int j = 0; j < row.cells.count; j++) {
        row.cells[j].style = cellStyle;
        row.cells[j].stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.left,
            lineAlignment: PdfVerticalAlignment.middle);
      }
    }
  }
//Draws the grid to the PDF page
  PdfLayoutResult gridResult = grid.draw(
    page: page,
    bounds: Rect.fromLTWH(20, 190, graphics.clientSize.width - 60,
        graphics.clientSize.height - 100),
    format: layoutFormat,
  )!;

  /// total paid
  String totalPays = 'Total Pay $totalPay BDT';
  Size vatSize = timesRoman.measureString(totalPays);
  PdfTextElement(
    text: totalPays,
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

  ///total due
  String totalDues = 'Total Due $totalDue BDT';
  Size textSize1 = timesRoman.measureString(totalDues);
  PdfTextElement(
    text: totalDues,
    font: timesRoman,
    brush: PdfSolidBrush(PdfColor(215, 44, 67)),
  ).draw(
    format: layoutFormat,
    page: gridResult.page,
    bounds: Rect.fromLTWH(
      graphics.clientSize.width - textSize1.width,
      gridResult.bounds.bottom + 50,
      0,
      0,
    ),
  );
  // sub total
  String totalAmounts = 'Total Amount $totalAmount BDT';
  Size subTotalSize = timesRoman.measureString(totalAmounts);
  PdfTextElement(
    text: totalAmounts,
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
  //Save the document
  List<int> bytes = await document.save();
  // print
  if (isSave) {
    try {
      await FileSaver.instance.saveFile(
          '$name Transaction statement$invoiceId.pdf',
          Uint8List.fromList(bytes),
          'PDF');
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  } else if (isPrint) {
    await Printing.layoutPdf(
        onLayout: (pdf.PdfPageFormat format) => Uint8List.fromList(bytes));
  } else {
    await Printing.sharePdf(
        bytes: Uint8List.fromList(bytes),
        filename: '$name Transaction statement$invoiceId.pdf');
  }
  document.dispose();
}
