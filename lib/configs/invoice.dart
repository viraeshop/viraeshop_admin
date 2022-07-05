import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:async';
//import 'package:js/js.dart' as js;
import 'package:flutter/services.dart' show rootBundle;

class Invoice {
  Future<void> createPDF({
    required String totalItems,    
    discountAmount,
    required subTotal,
    required List items,
    required String mobile,
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
        .drawImage(PdfBitmap(imageBytes), Rect.fromLTWH(0, 15, 100, 100));

    /// Mobile no.
    PdfTextElement element =
        PdfTextElement(text: 'Tel: 01710735425 01715041368', font: timesRoman);
    element.brush = brushColor;
    PdfLayoutResult result =
        element.draw(page: page, bounds: Rect.fromLTWH(10, 115, 0, 0))!;

    /// email address
    element =
        PdfTextElement(text: 'Email: viraeshop@gmail.com', font: timesRoman);
    element.brush = brushColor;
    result = element.draw(page: page, bounds: Rect.fromLTWH(10, 135, 0, 0))!;

    /// Address
    element = PdfTextElement(
        text: 'H-65, New Airport, Amtoli,Mohakhali,', font: timesRoman);
    element.brush = brushColor;
    result = element.draw(page: page, bounds: Rect.fromLTWH(10, 155, 0, 0))!;
    element = PdfTextElement(text: 'Dhaka-1212, Bangladesh.', font: timesRoman);
    element.brush = brushColor;
    result = element.draw(
      page: page,
      bounds: Rect.fromLTWH(10, 160, 0, 0),
    )!;

    /// date
    String currentDate = 'Date: ' + DateFormat.yMMMd().format(DateTime.now());
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
      bounds: Rect.fromLTWH(10, 195, 0, 0),
    )!;
    /// customer mobile    
    element = PdfTextElement(
      text: mobile,
      font: timesRoman,
    );
    element.brush = brushColor;
    result = element.draw(
      page: page,
      bounds: Rect.fromLTWH(10, 215, 0, 0),
    )!;
    /// customer address
    element = PdfTextElement(text: address, font: timesRoman);
    element.brush = brushColor;
    result = element.draw(
      page: page,
      bounds: Rect.fromLTWH(10, 230, 0, 0),
    )!;

    /// items
    element = PdfTextElement(
        text: '$totalItems Items (QTY $totalQuantity)', font: timesRoman);
    element.brush = PdfSolidBrush(PdfColor(29, 233, 182));
    result = element.draw(page: page, bounds: Rect.fromLTWH(10, 235, 0, 0))!;

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
    items.forEach((element) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = '${element['quantity']} X';
      row.cells[1].value = '${element['product_name']}';
      row.cells[2].value = '${element['unit_price']}';
      row.cells[3].value = '${element['product_price']}';
    });
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
      bounds: Rect.fromLTWH(20, 260, graphics.clientSize.width - 60,
          graphics.clientSize.height - 100),
      format: layoutFormat,
    )!;
    // vat
    String vat = 'VAT %';
    Size vatSize = timesRoman.measureString(vat);
    gridResult.page.graphics.drawString(vat, timesRoman,
        brush: PdfSolidBrush(color),
        bounds: Rect.fromLTWH(graphics.clientSize.width - vatSize.width,
            gridResult.bounds.bottom + 30, 0, 0));

    ///to add Discount
    Size textSize1 = timesRoman.measureString('Discount $discountAmount BDT');
    gridResult.page.graphics.drawString(
        'Discount $discountAmount BDT', timesRoman,
        brush: PdfBrushes.darkRed,
        bounds: Rect.fromLTWH(graphics.clientSize.width - textSize1.width,
            gridResult.bounds.bottom + 50, 0, 0));
    // sub total
    String subTotals = 'Sub Total $subTotal BDT';
    Size subTotalSize = timesRoman.measureString(subTotals);
    gridResult.page.graphics.drawString(subTotals, timesRoman,
        brush: PdfSolidBrush(color),
        bounds: Rect.fromLTWH(graphics.clientSize.width - subTotalSize.width,
            gridResult.bounds.bottom + 70, 0, 0));

    /// advance
    String advanceText = 'Advance $advance BDT';
    Size textSize2 = timesRoman.measureString(advanceText);
    gridResult.page.graphics.drawString(advanceText, timesRoman,
        brush: PdfSolidBrush(color),
        bounds: Rect.fromLTWH(graphics.clientSize.width - textSize2.width,
            gridResult.bounds.bottom + 90, 0, 0));

    /// Due
    String dueText = 'Due $due BDT';
    Size dueSize = timesRoman.measureString(dueText);
    gridResult.page.graphics.drawString(dueText, timesRoman,
        brush: PdfSolidBrush(color),
        bounds: Rect.fromLTWH(graphics.clientSize.width - dueSize.width,
            gridResult.bounds.bottom + 110, 0, 0));

    /// paid
    String paidText = 'Due $paid BDT';
    Size paidSize = timesRoman.measureString(paidText);
    gridResult.page.graphics.drawString(paidText, timesRoman,
        brush: PdfSolidBrush(color),
        bounds: Rect.fromLTWH(graphics.clientSize.width - paidSize.width,
            gridResult.bounds.bottom + 130, 0, 0));
    //Save the document
    List<int> bytes = document.save();
    //Dispose the document    
    //js.context['pdfData'] = base64.encode(bytes);
    //js.context['filename'] = 'Invoice_$invoiceId.pdf';
    //Timer.run(() {
     // js.context.callMethod('download');
    // });
    document.dispose();
  }
}
