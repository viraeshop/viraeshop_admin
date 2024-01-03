import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:printing/printing.dart';
import 'package:random_string/random_string.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:async';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:viraeshop_api/utils/utils.dart';

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
  document.pageSettings.margins.all = 0.5 * PdfPageFormat.inch;
  const double margin = 50;
  PdfPage page = document.pages.add();
  double maxContentHeight = page.graphics.clientSize.height - 2 * margin;
  double yPos = margin;
  double xPos = page.graphics.clientSize.width;
  PdfGraphics graphics = page.graphics;
  PdfSolidBrush brushColor = PdfSolidBrush(PdfColor(55, 63, 74));
  PdfColor color = PdfColor(55, 63, 74);
  PdfFont timesRoman = PdfStandardFont(PdfFontFamily.timesRoman, 14,
      style: PdfFontStyle.regular);
  PdfTextElement element;
  late PdfLayoutResult result;
  PdfLayoutFormat layoutFormat =
      PdfLayoutFormat(layoutType: PdfLayoutType.paginate);
  List contents = [
    PdfBitmap(imageBytes),
    'Tel: 01710735425 01324430921',
    'Email: viraeshop@gmail.com',
    'H-65, New Airport, Amtoli, Mohakhali,',
    'Dhaka-1212, Bangladesh.',
    'Date: $date',
    'Invoice No. $invoiceId',
    name,
    mobile,
    address,
    '$totalItems Items (QTY $totalQuantity)',
    items,
    'VAT %',
    'Discount $discountAmount BDT',
    'Sub Total $subTotal  BDT',
    'Advance $advance BDT',
    payList,
    'Due $due BDT',
    'Paid $paid BDT',
  ];
  List<int> contentOnRight = [5, 6, 12, 13, 14, 15, 16, 17, 18];
  for (int i = 0; i < contents.length; i++) {
    if (yPos > page.graphics.clientSize.height - margin) {
      // If not enough space, add a new page
      page = document.pages.add();
      // Reset yPos for the new page
      yPos = margin;
    }

    if (contents[i] is PdfBitmap) {
      page.graphics.drawImage(
        contents[i],
        const Rect.fromLTWH(margin, 15, 100, 100),
      );
      yPos += 100;
    } else if (contents[i] is String) {
      // This will check if the content is to be placed on right side
      Size textSize = timesRoman.measureString(contents[i]);
      if (contentOnRight.contains(i)) {
        element = PdfTextElement(text: contents[i], font: timesRoman);
        element.brush = brushColor;
        result = element.draw(
          page: result.page,
          bounds: Rect.fromLTWH(xPos - textSize.width,
              i > 6 ? result.bounds.bottom : yPos, 0, 0),
          format: layoutFormat,
        )!;
      } else {
        element = PdfTextElement(text: contents[i], font: timesRoman);
        element.brush = brushColor;
        result = element.draw(
          page: i == 1 ? page : result.page,
          bounds: Rect.fromLTWH(margin, yPos, 0, 0),
          format: layoutFormat,
        )!;
      }
      if (i == 7) {
        yPos -= textSize.height * 2;
      } else {
        yPos += textSize.height;
        if (i == 9) {
          yPos += textSize.height;
        }
      }
      //debugPrint(textSize.height.toString());
    } else {
      if (contentOnRight.contains(i)) {
        for (var content in contents[i]) {
          Timestamp timestamp = dateFromJson(content['createdAt']);
          final formatter = DateFormat('MM/dd/yyyy');
          String dateTime = formatter.format(
            timestamp.toDate(),
          );
          String paidText = '$dateTime  Pay ${content['paid']} BDT';
          Size textSize = timesRoman.measureString(paidText);
          element = PdfTextElement(text: paidText, font: timesRoman);
          element.brush = brushColor;
          result = element.draw(
            page: result.page,
            bounds: Rect.fromLTWH(xPos - textSize.width,
                result.bounds.bottom + textSize.height, 0, 0),
            format: layoutFormat,
          )!;
          yPos += textSize.height;
        }
      } else {
        PdfGrid grid = drawTable(items, color);
        result = grid.draw(
          page: result.page,
          bounds: Rect.fromLTWH(margin, yPos, 0, 0),
          format: layoutFormat,
        )!;
        //yPos += result.bounds.size.height;
        // debugPrint('Height${result.bounds.size.height.toString()}');
        // debugPrint('Page Height${(graphics.clientSize.height - 100).toString()}');
      }
    }
    // yPos += i == 0 ? 100 : result.bounds.height;
  }

  /// Logo
  //
  // /// Mobile no.
  // PdfTextElement element =
  //     PdfTextElement(text: , font: timesRoman);
  // element.brush = brushColor;
  // PdfLayoutResult result =
  //     element.draw(page: page, bounds: const Rect.fromLTWH(10, 120, 0, 0))!;
  //
  // /// email address
  // element =
  //     PdfTextElement(text: , font: timesRoman);
  // element.brush = brushColor;
  // result =
  //     element.draw(page: page, bounds: const Rect.fromLTWH(10, 135, 0, 0))!;
  //
  // /// Address
  // element = PdfTextElement(
  //     text:  font: timesRoman);
  // element.brush = brushColor;
  // result =
  //     element.draw(page: page, bounds: const Rect.fromLTWH(10, 155, 0, 0))!;
  // element = PdfTextElement(text: , font: timesRoman);
  // element.brush = brushColor;
  // result = element.draw(
  //   page: page,
  //   bounds: const Rect.fromLTWH(10, 170, 0, 0),
  // )!;
  //
  // /// date
  // String currentDate = ;
  // // Measures the width of the text to place it in the correct location
  // Size size = timesRoman.measureString(currentDate);
  // element = PdfTextElement(text: currentDate, font: timesRoman);
  // element.brush = brushColor;
  // result = element.draw(
  //     page: page,
  //     bounds:
  //         Rect.fromLTWH(graphics.clientSize.width - size.width, 175, 0, 0))!;
  //
  // /// Invoice Number
  // Size textSize = timesRoman.measureString('Invoice No. $invoiceId');
  // element = PdfTextElement(text:  font: timesRoman);
  // element.brush = brushColor;
  // result = element.draw(
  //   page: page,
  //   bounds:
  //       Rect.fromLTWH(graphics.clientSize.width - textSize.width, 195, 0, 0),
  // )!;
  //
  // /// Customer name
  // element = PdfTextElement(
  //   text: ,
  //   font: PdfStandardFont(
  //     PdfFontFamily.timesRoman,
  //     16,
  //     style: PdfFontStyle.bold,
  //   ),
  // );
  // element.brush = brushColor;
  // result = element.draw(
  //   page: page,
  //   bounds: const Rect.fromLTWH(10, 195, 0, 0),
  // )!;

  /// customer mobile
  // element = PdfTextElement(
  //   text: ,
  //   font: timesRoman,
  // );
  // element.brush = brushColor;
  // result = element.draw(
  //   page: page,
  //   bounds: const Rect.fromLTWH(10, 215, 0, 0),
  // )!;

  // /// customer address
  // element = PdfTextElement(text: address, font: timesRoman);
  // element.brush = brushColor;
  // result = element.draw(
  //   page: page,
  //   bounds: const Rect.fromLTWH(10, 230, 0, 0),
  // )!;
  //
  // /// items
  // element = PdfTextElement(
  //     text: , font: timesRoman);
  // element.brush = PdfSolidBrush(PdfColor(12, 187, 139));
  // result =
  //     element.draw(page: page, bounds: const Rect.fromLTWH(10, 250, 0, 0))!;

  /// Horizontal Line
  // graphics.drawLine(
  //     PdfPen(color, width: 1),
  //     Offset(0, result.bounds.bottom + 10),
  //     Offset(graphics.clientSize.width, result.bounds.bottom + 10));
  ///TODO: This will be added inside the loop

//Draws the grid to the PDF page

  // vat
  // String vat = ;
  // Size vatSize = timesRoman.measureString(vat);
  // PdfTextElement(
  //   text: vat,
  //   font: timesRoman,
  //   brush: PdfSolidBrush(color),
  // ).draw(
  //   format: layoutFormat,
  //   page: gridResult.page,
  //   bounds: Rect.fromLTWH(
  //     graphics.clientSize.width - vatSize.width,
  //     gridResult.bounds.bottom + 30,
  //     0,
  //     0,
  //   ),
  // );

  ///to add Discount
  // Size textSize1 = timesRoman.measureString();
  // PdfTextElement(
  //   text: 'Discount $discountAmount BDT',
  //   font: timesRoman,
  //   brush: PdfSolidBrush(PdfColor(215, 44, 67)),
  // ).draw(
  //     format: layoutFormat,
  //     page: gridResult.page,
  //     bounds: Rect.fromLTWH(graphics.clientSize.width - textSize1.width,
  //         gridResult.bounds.bottom + 50, 0, 0));

  // sub total
  // String subTotals = ;
  // Size subTotalSize = timesRoman.measureString(subTotals);
  // PdfTextElement(
  //   text: subTotals,
  //   font: timesRoman,
  //   brush: PdfSolidBrush(color),
  // ).draw(
  //   format: layoutFormat,
  //   page: gridResult.page,
  //   bounds: Rect.fromLTWH(
  //     graphics.clientSize.width - subTotalSize.width,
  //     gridResult.bounds.bottom + 70,
  //     0,
  //     0,
  //   ),
  // );

  /// advance
  // String advanceText = ;
  // Size textSize2 = timesRoman.measureString(advanceText);
  // PdfTextElement(
  //   text: advanceText,
  //   font: timesRoman,
  //   brush: PdfSolidBrush(color),
  // ).draw(
  //   format: layoutFormat,
  //   page: gridResult.page,
  //   bounds: Rect.fromLTWH(
  //     graphics.clientSize.width - textSize2.width,
  //     gridResult.bounds.bottom + 90,
  //     0,
  //     0,
  //   ),
  // );
  ///Todo: This will also be part of the loop
  ///pay list

  /// Due
  // String dueText = ;
  // Size dueSize = timesRoman.measureString(dueText);
  // PdfTextElement(
  //   text: dueText,
  //   font: timesRoman,
  //   brush: PdfSolidBrush(color),
  // ).draw(
  //   format: layoutFormat,
  //   page: gridResult.page,
  //   bounds: Rect.fromLTWH(
  //     graphics.clientSize.width - dueSize.width,
  //     gridResult.bounds.bottom + spacing,
  //     0,
  //     0,
  //   ),
  // );

  // /// paid
  // String paidText = ;
  // Size paidSize = timesRoman.measureString(paidText);
  // PdfTextElement(
  //   text: paidText,
  //   font: timesRoman,
  //   brush: PdfSolidBrush(color),
  // ).draw(
  //     page: gridResult.page,
  //     format: layoutFormat,
  //     bounds: Rect.fromLTWH(graphics.clientSize.width - paidSize.width,
  //         gridResult.bounds.bottom + spacing + 20, 0, 0));
  //
  // /// total amount
  // String amountText = ;
  // Size amountSize = timesRoman.measureString(amountText);
  // PdfTextElement(
  //   text: amountText,
  //   font: timesRoman,
  //   brush: PdfSolidBrush(color),
  // ).draw(
  //   page: gridResult.page,
  //   format: layoutFormat,
  //   bounds: Rect.fromLTWH(graphics.clientSize.width - amountSize.width,
  //       gridResult.bounds.bottom + spacing + 40, 0, 0),
  // );
  //Save the document
  List<int> bytes = await document.save();
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

PdfGrid drawTable(List items, PdfColor color) {
  PdfGrid grid = PdfGrid();
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
  return grid;
}
