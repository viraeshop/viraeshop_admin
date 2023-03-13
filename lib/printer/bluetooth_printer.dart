import 'dart:async';
import 'dart:typed_data';

import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/boxes.dart';

class BluetoothPrinter extends StatefulWidget {
  final List items;
  final bool isWithBusinessName;
  final List payList;
  final String invoiceId,
      name,
      mobile,
      address,
      discountAmount,
      subTotal,
      total,
      advance,
      paid,
      quantity,
      due,
      businessName;
  const BluetoothPrinter({
    required this.items,
    required this.invoiceId,
    required this.name,
    required this.mobile,
    required this.address,
    required this.advance,
    required this.discountAmount,
    required this.due,
    required this.paid,
    required this.subTotal,
    required this.total,
    required this.quantity,
    required this.isWithBusinessName,
    required this.payList,
    this.businessName = '',
    Key? key,
  }) : super(key: key);
  @override
  _BluetoothPrinterState createState() => _BluetoothPrinterState();
}

class _BluetoothPrinterState extends State<BluetoothPrinter> {
  bool connected = false;
  List<PrinterDevice> availableBluetoothDevices = [];
  BluetoothPrinter? selectedDevice;
  var printerManager = PrinterManager.instance;
  @override
  void initState() {
    updateConnected();
    super.initState();
  }

  void updateConnected() async {
    PrinterManager.instance.stateBluetooth.listen((event) {
      if (kDebugMode) {
        print(event);
      }
      if(event == BTStatus.connected){
        setState(() {
          connected = true;
        });
      }else if(event == BTStatus.none){
        setState(() {
          connected = false;
        });
      }
    });
  }

  Future<void> getBluetoothDevices() async {
    PrinterManager.instance
        .discovery(type: PrinterType.bluetooth, isBle: false)
        .listen((device) {
      setState(() {
        availableBluetoothDevices.add(device);
      });
    });
  }

  Future<void> setConnect(PrinterDevice printer) async {
    try{
      await PrinterManager.instance.connect(
        type: PrinterType.bluetooth,
        model: BluetoothPrinterInput(
          name: printer.name,
          address: printer.address!,
          isBle: false,
          autoConnect: true,
        ),
      );
      setState(() {
        connected = true;
      });
    }catch (e){
      debugPrint(e.toString());
    }
  }

  Future<void> printTicket() async {
     BTStatus isConnected = printerManager.currentStatusBT;
    if (kDebugMode) {
      print(isConnected);
    }
    if (isConnected == BTStatus.connected) {
      List<int> bytes = await printDemoReceipt();
      if (kDebugMode) {
        print(bytes);
      }
      await printerManager.bluetoothPrinterConnector.send(bytes);
      // if (kDebugMode) {
      //   print("Print ${}");
      // }
    } else {
      //Handle Not Connected Scenario
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
    final ByteData data = await rootBundle.load('assets/images/oasisvira.png');
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
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += receipt.text(
      'Web: www.viraeshop.com',
      styles: const PosStyles(align: PosAlign.left),
    );
    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    bytes += receipt.text(timestamp,
        styles: const PosStyles(align: PosAlign.right), linesAfter: 1);
    bytes += receipt.text(
      'Invoice No. ${widget.invoiceId}',
      linesAfter: 1,
      styles: const PosStyles(
        align: PosAlign.right,
      ),
    );
    if (widget.isWithBusinessName) {
      bytes += receipt.text(
        widget.businessName,
        styles: const PosStyles(
          align: PosAlign.left,
          bold: true,
        ),
      );
    }
    bytes += receipt.text(
      widget.name,
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += receipt.text(
      widget.mobile,
      styles: const PosStyles(
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
        text: 'QTY ${widget.quantity}',
        width: 2,
        styles: const PosStyles(
          bold: true,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: 'Items ${widget.items.length.toString()}',
        width: 6,
        styles: const PosStyles(
          bold: true,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: 'Price',
        width: 2,
        styles: const PosStyles(
          bold: true,
          align: PosAlign.right,
        ),
      ),
      PosColumn(
        text: 'Amount',
        width: 2,
        styles: const PosStyles(
          bold: true,
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += receipt.hr();
    for (var element in widget.items) {
      bytes += receipt.row([
        PosColumn(
          text: '${element['quantity']}x',
          width: 1,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
            text: element['productName'] + ' (${element['productId']})',
            width: 7),
        PosColumn(
          text: element['unitPrice'].toString(),
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: element['productPrice'].toString(),
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    bytes += receipt.hr();
    bytes += receipt.text('VAT: %',
        styles: const PosStyles(
          align: PosAlign.right,
        ));
    bytes += receipt.text('Total: ${widget.total}$bdtSign',
        styles: const PosStyles(
          align: PosAlign.right,
        ));    
    bytes += receipt.text('Discount: ${widget.discountAmount}$bdtSign',
        styles: const PosStyles(
          align: PosAlign.right,
        ));
    bytes += receipt.text('Sub-Total: ${widget.subTotal}$bdtSign',
        styles: const PosStyles(
          align: PosAlign.right,
        ));
    bytes += receipt.text('Advance: ${widget.advance}$bdtSign',
        styles: const PosStyles(
          align: PosAlign.right,
        ));
    if (widget.payList.isNotEmpty) {
      for (var pay in widget.payList) {
        Timestamp timestamp = pay['date'];
        final formatter = DateFormat('MM/dd/yyyy');
        String dateTime = formatter.format(
          timestamp.toDate(),
        );
        bytes += receipt.text('$dateTime Pay ${pay['paid']}',
            styles: const PosStyles(
              align: PosAlign.right,
            ));
      }
    }
    bytes += receipt.text('Due: ${widget.due}$bdtSign',
        styles: const PosStyles(
          align: PosAlign.right,
        ));
    bytes += receipt.text('Paid: ${widget.paid}$bdtSign',
        styles: const PosStyles(
          align: PosAlign.right,
        ));
    bytes += receipt.feed(2);
    bytes += receipt.text('Thank you!',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    receipt.feed(1);
    bytes += receipt.feed(2);
    bytes += receipt.qrcode('www.viraeshop.com');
    receipt.cut();

    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(FontAwesomeIcons.chevronLeft),
            color: kSubMainColor,
            iconSize: 20.0,
          ),
          title: const Text(
            'Printer',
            style: kAppBarTitleTextStyle,
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Search Paired Bluetooth"),
              TextButton(
                onPressed: () {
                  getBluetoothDevices();
                },
                child: const Text(
                  "Search",
                  style: kProductNameStylePro,
                ),
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
                        setConnect(availableBluetoothDevices[index]);
                      },
                      title: Text(availableBluetoothDevices[index].name),
                      subtitle: Text(
                        // For now we will just use the variable 'connected'
                        // in other to change the status message
                        // since we currently have one printer
                        // but subsequently this must be changed for every printer
                        connected ? 'Connected' : 'Click to connect',
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
                child: const Text(
                  "Print Ticket",
                  style: kProductNameStylePro,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
