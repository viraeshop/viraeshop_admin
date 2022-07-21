import 'dart:typed_data';
import 'package:flutter/material.dart' hide Image;
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io' show Platform;
import 'package:image/image.dart';
import 'package:intl/intl.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class Print extends StatefulWidget {
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
  Print(
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
  _PrintState createState() => _PrintState();
}

class _PrintState extends State<Print> {

  PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  String? _devicesMsg;
  BluetoothManager bluetoothManager = BluetoothManager.instance;
 // @override
  //void initState() {
   // bluetoothManager.scan(timeout: Duration(seconds: 5)).listen((event) {
    //  print('name: ${event.name}');
   // });
  //  super.initState();
 // }
  @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   if (Platform.isAndroid) {
  //
  //     // bluetoothManager.state.listen((val) {
  //     //   print('state = $val');
  //     //   //if (!mounted) return;
  //     //   if (val == 12) {
  //     //     print('on');
  //     //     initPrinter();
  //     //   } else if (val == 10) {
  //     //     print('off');
  //     //     setState(() => _devicesMsg = 'Bluetooth Disconnect!');
  //     //   }
  //     // });
  //   } else {
  //     initPrinter();
  //   }
  //
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
           // _printerManager.startScan(Duration(seconds: 4));
            _printerManager.scanResults.listen((event) {
              debugPrint('Devices found: ${event.length}');
            }).onError((error){
              debugPrint('Error: $error');
            });
            // Navigator.pop(context)
          },
          icon: Icon(FontAwesomeIcons.chevronLeft),
          color: kSubMainColor,
          iconSize: 20.0,
        ),
        title: Text('Print', style: kAppBarTitleTextStyle,),
      ),
      body: _devices.isEmpty
          ? Center(child: Text(_devicesMsg ?? ''))
          : ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (c, i) {
          return ListTile(
            leading: Icon(Icons.print),
            title: Text(_devices[i].name!),
            subtitle: Text(_devices[i].address!),
            onTap: () {
              _startPrint(_devices[i]);
            },
          );
        },
      ),
    );
  }

  void initPrinter() {
    _printerManager.startScan(Duration(seconds: 2));
    _printerManager.scanResults.listen((val) {
      if (!mounted) return;
      print('devices: $val');
      setState(() => _devices = val);
      if (_devices.isEmpty) setState(() => _devicesMsg = 'No Devices');
    });
  }

  Future<void> _startPrint(PrinterBluetooth printer) async {
    final profile = await CapabilityProfile.load();
    _printerManager.selectPrinter(printer);
    final result = await _printerManager.printTicket(await printDemoReceipt(PaperSize.mm80, profile));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(result.msg),
      ),
    );
  }
  Future<List<int>> printDemoReceipt(PaperSize paper, CapabilityProfile profile) async {
    final Generator receipt = Generator(paper, profile);
    List<int> bytes = [];
    // Print image
    final ByteData data = await rootBundle.load('assets/images/DONE.png');
    final Uint8List imageBytes = data.buffer.asUint8List();
    final Image? image = decodeImage(imageBytes);
    bytes += receipt.image(image!, align: PosAlign.left);
    bytes += receipt.text(
      'Tel: +880 1710735425 01324430921',
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
      PosColumn(text: '${widget.items.length.toString()} Items (QTY ${widget.quantity})', width: 7, styles: PosStyles()),
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
   widget. items.forEach((element) {
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
  // Future<Ticket> _ticket(PaperSize paper) async {
  //   final ticket = Ticket(paper);
  //   int total = 0;
  //
  //   // Image assets
  //   final ByteData data = await rootBundle.load('assets/store.png');
  //   final Uint8List bytes = data.buffer.asUint8List();
  //   final Image? image = decodeImage(bytes);
  //   ticket.image(image);
  //   ticket.text(
  //     'TOKO KU',
  //     styles: PosStyles(align: PosAlign.center,height: PosTextSize.size2,width: PosTextSize.size2),
  //     linesAfter: 1,
  //   );
  //
  //   for (var i = 0; i < widget.data.length; i++) {
  //     total += widget.data[i]['total_price'];
  //     ticket.text(widget.data[i]['title']);
  //     ticket.row([
  //       PosColumn(
  //           text: '${widget.data[i]['price']} x ${widget.data[i]['qty']}',
  //           width: 6),
  //       PosColumn(text: 'Rp ${widget.data[i]['total_price']}', width: 6),
  //     ]);
  //   }
  //
  //   ticket.feed(1);
  //   ticket.row([
  //     PosColumn(text: 'Total', width: 6, styles: PosStyles(bold: true)),
  //     PosColumn(text: 'Rp $total', width: 6, styles: PosStyles(bold: true)),
  //   ]);
  //   ticket.feed(2);
  //   ticket.text('Thank You',styles: PosStyles(align: PosAlign.center, bold: true));
  //   ticket.cut();
  //
  //   return ticket;
  // }

  @override
  void dispose() {
    _printerManager.stopScan();
    super.dispose();
  }

}