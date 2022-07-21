import 'dart:typed_data';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart' hide Image;
// import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:flutter/services.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:image/image.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';

class PosPrinter extends StatefulWidget {
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
  PosPrinter(
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
  _PosPrinterState createState() => _PosPrinterState();
}

class _PosPrinterState extends State<PosPrinter> {
  // String? localIp = '';
  // List<String> devices = [];
  // bool isDiscovering = false;
  // int found = -1;
  // TextEditingController portController = TextEditingController(text: '9100');
  // final info = NetworkInfo();
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  List items = [];
  @override
  void initState() {
    // TODO: implement initState
    items = widget.items;
    printerManager.scanResults.listen((devices){
      print('UI: Devices found ${devices.length}');
      setState(() {
        _devices = devices;
      });
    });
    super.initState();
  }
  void _startScanDevices() {
    setState(() {
      _devices = [];
    });
    printerManager.startScan(Duration(seconds: 4));
  }

  void _stopScanDevices() {
    printerManager.stopScan();
  }
  // void discover(BuildContext ctx) async {
  //   setState(() {
  //     isDiscovering = true;
  //     devices.clear();
  //     found = -1;
  //   });
  //
  //   String? ip;
  //   try {
  //     ip = await info.getWifiIP();
  //     print('local ip:\t$ip');
  //   } catch (e) {
  //     final snackBar = SnackBar(
  //         content: Text('WiFi is not connected', textAlign: TextAlign.center));
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //
  //     return;
  //   }
  //   setState(() {
  //     localIp = ip;
  //   });
  //
  //   final String subnet = ip!.substring(0, ip.lastIndexOf('.'));
  //   int port = 9100;
  //   try {
  //     port = int.parse(portController.text);
  //   } catch (e) {
  //     portController.text = port.toString();
  //   }
  //   print('subnet:\t$subnet, port:\t$port');
  //
  //   final stream = NetworkAnalyzer.discover2(subnet, port);
  //
  //   stream.listen((NetworkAddress addr) {
  //     if (addr.exists) {
  //       print('Found device: ${addr.ip}');
  //       setState(() {
  //         devices.add(addr.ip);
  //         found = devices.length;
  //       });
  //     }
  //   })
  //     ..onDone(() {
  //       setState(() {
  //         isDiscovering = false;
  //         found = devices.length;
  //       });
  //     })
  //     ..onError((dynamic e) {
  //       final snackBar = SnackBar(
  //           content: Text('Unexpected exception', textAlign: TextAlign.center));
  //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //     });
  // }

  Future<List<int>> printDemoReceipt(PaperSize paper, CapabilityProfile profile) async {
    final Generator receipt = Generator(paper, profile);
    List<int> bytes = [];
    // Print image
    final ByteData data = await rootBundle.load('assets/images/DONE.png');
    final Uint8List imageBytes = data.buffer.asUint8List();
    final Image? image = decodeImage(imageBytes);
    bytes += receipt.image(image!, align: PosAlign.left);
    bytes += receipt.text(
      'Tel: 01710735425 01715041368',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += receipt.text(
      'Email: viraeshop@gmail.com',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += receipt.text(
      'H-65, New Airport, Amtoli,Mohakhali,',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += receipt.text(
      'Dhaka-1212, Bangladesh.',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += receipt.text(
      'Web: www.viraeshop.com',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += receipt.text(
      'Invoice No. ${widget.invoiceId}',
      linesAfter: 1,
      styles: PosStyles(
        align: PosAlign.right,
      ),
    );
    bytes += receipt.text(
      '${widget.name}',
      styles: PosStyles(
        align: PosAlign.left,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += receipt.text(
      '${widget.mobile}',
      styles: PosStyles(
        align: PosAlign.left,
      ),
    );
    bytes += receipt.text(
      '${widget.address}',
      styles: PosStyles(
        align: PosAlign.left,
      ),
    );
    // printer.hr();
    bytes += receipt.row([
      PosColumn(text: '${items.length.toString()} Items (QTY ${widget.quantity})', width: 7, styles: PosStyles()),
      PosColumn(
        text: 'Price(BDT)',
        width: 2,
        styles: PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: 'Amount(BDT)',
        width: 2,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    items.forEach((element) {
      bytes += receipt.row([
        PosColumn(text: '${element['quantity'].toString()}', width: 1),
        PosColumn(text: '${element['product_name'].toString()}', width: 7),
        PosColumn(
            text: '${element['unit_price'].toString()}', width: 2, styles: PosStyles(align: PosAlign.right),),
        PosColumn(
            text: '${element['product_price'].toString()}', width: 2, styles: PosStyles(align: PosAlign.right),),
      ]);
    });
    bytes += receipt.emptyLines(2);
    bytes += receipt.row([
      PosColumn(
          text: 'VAT',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: '%',
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += receipt.row([
      PosColumn(
          text: 'Discount',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: '${widget.discountAmount}',
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += receipt.row([
      PosColumn(
          text: 'Sub Total',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: '${widget.subTotal} BDT',
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += receipt.row([
      PosColumn(
          text: 'Advance',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: '${widget.advance} BDT',
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += receipt.row([
      PosColumn(
          text: 'Due',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: '${widget.due} BDT',
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += receipt.row([
      PosColumn(
          text: 'Paid',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: '${widget.paid} BDT',
          width: 4,
          styles: PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += receipt.feed(2);
    bytes += receipt.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    bytes += receipt.text(timestamp,
        styles: PosStyles(align: PosAlign.center), linesAfter: 2);

    // Print QR Code from image
    // try {
    //   const String qrData = 'example.com';
    //   const double qrSize = 200;
    //   final uiImg = await QrPainter(
    //     data: qrData,
    //     version: QrVersions.auto,
    //     gapless: false,
    //   ).toImageData(qrSize);
    //   final dir = await getTemporaryDirectory();
    //   final pathName = '${dir.path}/qr_tmp.png';
    //   final qrFile = File(pathName);
    //   final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
    //   final img = decodeImage(imgFile.readAsBytesSync());
    //   printer.image(img);
    // } catch (e) {
    //   print(e);
    // }
    // Print QR Code using native function
    // printer.qrcode('example.com');
    receipt.feed(1);
    receipt.cut();

    return bytes;
  }

  void _testPrint(PrinterBluetooth printer) async {
    printerManager.selectPrinter(printer);

    // TODO Don't forget to choose printer's paper
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();

    // TEST PRINT
    // final PosPrintResult res =
    // await printerManager.printTicket(await testTicket(paper));

    // DEMO RECEIPT
    final PosPrintResult res = await printerManager.printTicket((await printDemoReceipt(paper, profile)));
    snackBar(text: res.msg, context: context);
  }
  
  // void testPrint(String printerIp, BuildContext ctx) async {
  //   // TODO Don't forget to choose printer's paper size
  //   const PaperSize paper = PaperSize.mm80;
  //   final profile = await CapabilityProfile.load();
  //   final printer = NetworkPrinter(paper, profile);
  //
  //   final PosPrintResult res = await printer.connect(printerIp, port: 9100);
  //
  //   if (res == PosPrintResult.success) {
  //     // DEMO RECEIPT
  //     await printDemoReceipt(printer);
  //     // TEST PRINT
  //     // await testReceipt(printer);
  //     printer.disconnect();
  //   }
  //
  //   final snackBar =
  //       SnackBar(content: Text(res.msg, textAlign: TextAlign.center));
  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(FontAwesomeIcons.chevronLeft),
          color: kSubMainColor,
          iconSize: 20.0,
        ),
        title: Text('Print Receipt'),
      ),
      body: ListView.builder(
          itemCount: _devices.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () => _testPrint(_devices[index]),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 60,
                    padding: EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.print),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(_devices[index].name ?? ''),
                              Text(_devices[index].address!),
                              Text(
                                'Click to print a test receipt',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(),
                ],
              ),
            );
          }),
      floatingActionButton: StreamBuilder<bool>(
        stream: printerManager.isScanningStream,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: _stopScanDevices,
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
              child: Icon(Icons.search),
              backgroundColor: kNewMainColor,
              onPressed: _startScanDevices,
            );
          }
        },
      ),
    );
  }
}
