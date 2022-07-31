import 'dart:async';
import 'dart:typed_data';

import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class BluetoothPrinter extends StatefulWidget {
  final List items;
  final String invoiceId,
      name,
      mobile,
      address,
      discountAmount,
      subTotal,
      advance,
      paid,
      quantity,
      due;
  BluetoothPrinter(
      {required this.items,
        required this.invoiceId,
        required this.name,
        required this.mobile,
        required this.address,
        required this.advance,
        required this.discountAmount,
        required this.due,
        required this.paid,
        required this.subTotal,
        required this.quantity,
      });
  @override
  _BluetoothPrinterState createState() => _BluetoothPrinterState();
}

class _BluetoothPrinterState extends State<BluetoothPrinter> {
  @override
  void initState() {
    super.initState();
  }

  bool connected = false;
  List availableBluetoothDevices = [];

  Future<void> getBluetooth() async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    setState(() {
      availableBluetoothDevices = bluetooths ?? [];
    });
  }

  Future<void> setConnect(String mac) async {
    final String? result = await BluetoothThermalPrinter.connect(mac);
    print("state conneected $result");
    if (result == "true") {
      setState(() {
        connected = true;
      });
    }
  }

  Future<void> printTicket() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    print(isConnected);
    if (isConnected == "true") {
      List<int> bytes = await printDemoReceipt();
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    } else {
      //Hadnle Not Connected Senario
    }
  }

  // Future<void> printGraphics() async {
  //   String? isConnected = await BluetoothThermalPrinter.connectionStatus;
  //   if (isConnected == "true") {
  //     List<int> bytes = await getGraphicsTicket();
  //     final result = await BluetoothThermalPrinter.writeBytes(bytes);
  //     print("Print $result");
  //   } else {
  //     //Hadnle Not Connected Senario
  //   }
  // }

  // Future<List<int>> getGraphicsTicket() async {
  //   List<int> bytes = [];
  //
  //   CapabilityProfile profile = await CapabilityProfile.load();
  //   final generator = Generator(PaperSize.mm80, profile);
  //
  //   // Print QR Code using native function
  //   bytes += generator.qrcode('example.com');
  //
  //   bytes += generator.hr();
  //
  //   // Print Barcode using native function
  //   final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
  //   bytes += generator.barcode(Barcode.upcA(barData));
  //
  //   bytes += generator.cut();
  //
  //   return bytes;
  // }
  Future<List<int>> printDemoReceipt() async {
    CapabilityProfile profile = await CapabilityProfile.load();
    final Generator receipt = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    // Print image
    final ByteData data = await rootBundle.load('assets/images/DONE.png');
    final Uint8List imageBytes = data.buffer.asUint8List();
    final Image? image = decodeImage(imageBytes);
    bytes += receipt.image(image!, align: PosAlign.center);
    bytes += receipt.text(
      'Tel: +880 1710735425 01324430921',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += receipt.text(
      'Email: viraeshop@gmail.com',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += receipt.text(
      'H-65, New Airport, Amtoli,Mohakhali,',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += receipt.text(
      'Dhaka-1212, Bangladesh.',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += receipt.text(
      'Web: www.viraeshop.com',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += receipt.text(
      'Invoice No. ${widget.invoiceId}',
      linesAfter: 1,
      styles: const PosStyles(
        align: PosAlign.right,
      ),
    );
    bytes += receipt.text(
      widget.name,
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += receipt.text(
      widget.mobile,
      styles: const  PosStyles(
        align: PosAlign.left,
      ),
    );
    bytes += receipt.text(
      widget.address,
      styles: const PosStyles(
        align: PosAlign.left,
      ),
    );
    bytes += receipt.hr();
    bytes += receipt.row([
      PosColumn(
        text: 'Quantity',
        width: 2,
        styles: const  PosStyles(
          bold: true,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
          text: '${widget.items.length.toString()} Items (QTY ${widget.quantity})',
          width: 6,
          styles: const PosStyles(
            bold: true,
            align: PosAlign.left,
          ),),
      PosColumn(
        text: 'Price(BDT)',
        width: 2,
        styles: const PosStyles(
          bold: true,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: 'Amount(BDT)',
        width: 2,
        styles: const PosStyles(
          bold: true,
          align: PosAlign.left,
        ),
      ),
    ]);
    bytes += receipt.hr();
   for (var element in widget.items) {
      bytes += receipt.row([
        PosColumn(text: element['quantity'].toString(), width: 1),
        PosColumn(text: element['product_name']+(element['product_id']), width: 7),
        PosColumn(
          text: element['unit_price'].toString(), width: 2, styles: const PosStyles(align: PosAlign.right),),
        PosColumn(
          text: element['product_price'].toString(), width: 2, styles: const PosStyles(align: PosAlign.right),),
      ]);
    }
    bytes += receipt.hr();
    bytes += receipt.text(
      'VAT: %',
      styles: const PosStyles(
        align: PosAlign.right,
      )
    );
    bytes += receipt.text(
      'Discount: ${widget.discountAmount}BDT',
      styles: const PosStyles(
        align: PosAlign.right,
      )
    );
    bytes += receipt.text(
      'Sub-Total: ${widget.subTotal}BDT',
      styles: const PosStyles(
        align: PosAlign.right,
      )
    );
    bytes += receipt.text(
      'Advance: ${widget.advance}BDT',
      styles: const PosStyles(
        align: PosAlign.right,
      )
    );
    bytes += receipt.text(
      'Due: ${widget.due}BDT',
      styles: const PosStyles(
        align: PosAlign.right,
      )
    );
    bytes += receipt.text(
      'Paid: ${widget.paid}BDT',
      styles: const PosStyles(
        align: PosAlign.right,
      )
    );
    bytes += receipt.feed(2);
    bytes += receipt.text('Thank you!',
        styles: const PosStyles(align: PosAlign.center, bold: true));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    bytes += receipt.text(timestamp,
        styles: const PosStyles(align: PosAlign.center), linesAfter: 2);
    receipt.feed(1);
    bytes += receipt.feed(2);
    bytes += receipt.qrcode('www.viraeshop.com');
    receipt.cut();

    return bytes;
  }
  // Future<List<int>> getTicket() async {
  //   List<int> bytes = [];
  //   CapabilityProfile profile = await CapabilityProfile.load();
  //   final generator = Generator(PaperSize.mm80, profile);
  //
  //   bytes += generator.text("Demo Shop",
  //       styles: const PosStyles(
  //         align: PosAlign.center,
  //         height: PosTextSize.size2,
  //         width: PosTextSize.size2,
  //       ),
  //       linesAfter: 1);
  //
  //   bytes += generator.text(
  //       "18th Main Road, 2nd Phase, J. P. Nagar, Bengaluru, Karnataka 560078",
  //       styles: const PosStyles(align: PosAlign.center));
  //   bytes += generator.text('Tel: +919591708470',
  //       styles: const PosStyles(align: PosAlign.center));
  //
  //   bytes += generator.hr();
  //   bytes += generator.row([
  //     PosColumn(
  //         text: 'No',
  //         width: 1,
  //         styles: const PosStyles(align: PosAlign.left, bold: true)),
  //     PosColumn(
  //         text: 'Item',
  //         width: 5,
  //         styles: const PosStyles(align: PosAlign.left, bold: true)),
  //     PosColumn(
  //         text: 'Price',
  //         width: 2,
  //         styles: const PosStyles(align: PosAlign.center, bold: true)),
  //     PosColumn(
  //         text: 'Qty',
  //         width: 2,
  //         styles: const PosStyles(align: PosAlign.center, bold: true)),
  //     PosColumn(
  //         text: 'Total',
  //         width: 2,
  //         styles: const PosStyles(align: PosAlign.right, bold: true)),
  //   ]);
  //
  //   bytes += generator.row([
  //     PosColumn(text: "1", width: 1),
  //     PosColumn(
  //         text: "Tea",
  //         width: 5,
  //         styles: const PosStyles(
  //           align: PosAlign.left,
  //         )),
  //     PosColumn(
  //         text: "10",
  //         width: 2,
  //         styles: const PosStyles(
  //           align: PosAlign.center,
  //         )),
  //     PosColumn(text: "1", width: 2, styles: const PosStyles(align: PosAlign.center)),
  //     PosColumn(text: "10", width: 2, styles: const PosStyles(align: PosAlign.right)),
  //   ]);
  //
  //   bytes += generator.row([
  //     PosColumn(text: "2", width: 1),
  //     PosColumn(
  //         text: "Sada Dosa",
  //         width: 5,
  //         styles: const PosStyles(
  //           align: PosAlign.left,
  //         )),
  //     PosColumn(
  //         text: "30",
  //         width: 2,
  //         styles: const PosStyles(
  //           align: PosAlign.center,
  //         )),
  //     PosColumn(text: "1", width: 2, styles: const PosStyles(align: PosAlign.center)),
  //     PosColumn(text: "30", width: 2, styles: const PosStyles(align: PosAlign.right)),
  //   ]);
  //
  //   bytes += generator.row([
  //     PosColumn(text: "3", width: 1),
  //     PosColumn(
  //         text: "Masala Dosa",
  //         width: 5,
  //         styles: const PosStyles(
  //           align: PosAlign.left,
  //         )),
  //     PosColumn(
  //         text: "50",
  //         width: 2,
  //         styles: const PosStyles(
  //           align: PosAlign.center,
  //         )),
  //     PosColumn(text: "1", width: 2, styles: const PosStyles(align: PosAlign.center)),
  //     PosColumn(text: "50", width: 2, styles: const PosStyles(align: PosAlign.right)),
  //   ]);
  //
  //   bytes += generator.row([
  //     PosColumn(text: "4", width: 1),
  //     PosColumn(
  //         text: "Rova Dosa",
  //         width: 5,
  //         styles: const PosStyles(
  //           align: PosAlign.left,
  //         )),
  //     PosColumn(
  //         text: "70",
  //         width: 2,
  //         styles: const PosStyles(
  //           align: PosAlign.center,
  //         )),
  //     PosColumn(text: "1", width: 2, styles: const PosStyles(align: PosAlign.center)),
  //     PosColumn(text: "70", width: 2, styles: const PosStyles(align: PosAlign.right)),
  //   ]);
  //
  //   bytes += generator.hr();
  //
  //   bytes += generator.row([
  //     PosColumn(
  //         text: 'TOTAL',
  //         width: 6,
  //         styles: const PosStyles(
  //           align: PosAlign.left,
  //           height: PosTextSize.size4,
  //           width: PosTextSize.size4,
  //         )),
  //     PosColumn(
  //         text: "160",
  //         width: 6,
  //         styles: const PosStyles(
  //           align: PosAlign.right,
  //           height: PosTextSize.size4,
  //           width: PosTextSize.size4,
  //         )),
  //   ]);
  //
  //   bytes += generator.hr(ch: '=', linesAfter: 1);
  //
  //   // ticket.feed(2);
  //   bytes += generator.text('Thank you!',
  //       styles: const PosStyles(align: PosAlign.center, bold: true));
  //
  //   bytes += generator.text("26-11-2020 15:22:45",
  //       styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
  //
  //   bytes += generator.text(
  //       'Note: Goods once sold will not be taken back or exchanged.',
  //       styles: const PosStyles(align: PosAlign.center, bold: false));
  //   bytes += generator.cut();
  //   return bytes;
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: const Icon(FontAwesomeIcons.chevronLeft),
            color: kSubMainColor,
            iconSize: 20.0,
          ),
          title: const Text('Printer', style: kAppBarTitleTextStyle, ),
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Search Paired Bluetooth"),
              TextButton(
                onPressed: () {
                  getBluetooth();
                },
                child: const Text("Search", style: kProductNameStylePro,),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: availableBluetoothDevices.isNotEmpty
                      ? availableBluetoothDevices.length
                      : 0,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        String select = availableBluetoothDevices[index];
                        List list = select.split("#");
                        // String name = list[0];
                        String mac = list[1];
                        setConnect(mac);
                      },
                      title: Text('${availableBluetoothDevices[index]}'),
                      subtitle: Text(
                        // For now we will just use the variable 'connected'
                        // in other to change the status message
                        // since we currently have one printer
                        // but subsequently this must be changed for every printer
                      connected ? "Connected" : 'Click to connect',
                        style: kProductNameStylePro,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              // TextButton(
              //   onPressed: connected ? printGraphics : null,
              //   child: const Text("Print"),
              // ),
              TextButton(
                onPressed: connected ? printTicket : null,
                child: const Text("Print Ticket", style: kProductNameStylePro,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
