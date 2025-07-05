import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/invoice.dart';
import 'package:viraeshop_admin/configs/share_invoice.dart';
import 'package:viraeshop_admin/printer/bluetooth_printer.dart';

import '../components/ui_components/delete_popup.dart';
import '../utils/network_utilities.dart';

class ReceiptScreen extends StatefulWidget {
  final Map data;
  bool isFromOrder;
  ReceiptScreen({super.key, required this.data, this.isFromOrder = false});
  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  DateTime date = DateTime.now();
  List<Map<String, dynamic>> items = [];
  String quantity = '0';
  String role = '';
  @override
  void initState() {
    // TODO: implement initState
    List<Map<String, dynamic>> item = widget.data['items'];
    Timestamp timestamp = widget.data['date'];
    num totalQuantity = 0;
    for (var element in item) {
      totalQuantity += element['quantity'];
    }
    setState(() {
      date = timestamp.toDate();
      items = item;
      quantity = totalQuantity.toString();
      if (widget.isFromOrder) {
        role = widget.data['role'];
      } else {
        role = widget.data['customer_role'];
      }
    });
    super.initState();
  }

  bool isLoading = false;
  bool isManageDue = Hive.box('adminInfo').get('isManageDue');
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(
        color: kNewMainColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: kSelectedTileColor),
          elevation: 0.0,
          backgroundColor: kBackgroundColor,
          title: Text(
            widget.isFromOrder ? 'Order' : 'Reciept',
            style: kAppBarTitleTextStyle,
          ),
          centerTitle: true,
          titleTextStyle: kTextStyle1,
          actions: [
           if(isManageDue) IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return DeletePopup(
                        onDelete: () async {
                          setState(() {
                            isLoading = true;
                          });
                          Navigator.pop(context);
                          try {
                            await NetworkUtility.deleteInvoice(
                                widget.isFromOrder
                                    ? widget.data['orderId']
                                    : widget.data['invoice_id']);
                            Navigator.pop(context);
                          } on FirebaseException catch (e) {
                            if (kDebugMode) {
                              print(e.message);
                            }
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                      );
                    });
              },
              icon: const Icon(Icons.delete),
              color: kRedColor,
              iconSize: 30.0,
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100.0,
                    width: 100.0,
                    child: Image.asset('assets/images/DONE.png'),
                  ),
                  const Text(
                    'Call 01710735425 01324430921',
                    style: kProductNameStylePro,
                  ),
                  const Text(
                    'Email: viraeshop@gmail.com',
                    style: kProductNameStylePro,
                  ),
                  const Text(
                    'H-65, New Airport, Amtoli,Mohakhali,',
                    style: kProductNameStylePro,
                  ),
                  const Text(
                    'Dhaka-1212, Bangladesh.',
                    style: kProductNameStylePro,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: kBlackColor,
                      ),
                      borderRadius: BorderRadius.circular(
                        4.0,
                      ),
                    ),
                    child: Text(
                      DateFormat.yMMMd().format(date),
                      style: kProductNameStylePro,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    widget.isFromOrder
                        ? 'Order No ${widget.data['orderId']}'
                        : 'Invoice No ${widget.data['invoice_id']}',
                    style: kProductNameStyle,
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              // Text(
              //   widget.isFromOrder
              //       ? role != 'general'
              //           ? '${widget.data['customer_info']['business_name']}'
              //           : widget.data['customer_info']['business_name']
              //       : role != 'general'
              //           ? '${widget.data['user_info']['business_name']}(${widget.data['user_info']['name']})'
              //           : '${widget.data['user_info']['name']}',
              //   style: kProductNameStyle,
              // ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (role != 'general')
                    if (!widget.isFromOrder)
                      Text(
                        '${widget.data['user_info']['business_name']}',
                        style: kProductNameStyle,
                      )
                    else
                      Text(
                        '${widget.data['customer_info']['business_name']}',
                        style: kProductNameStyle,
                      ),
                  if (widget.isFromOrder)
                    Text(
                      '${widget.data['customer_info']['customer_name']}',
                      style: kProductNameStyle,
                    )
                  else
                    Text(
                      '${widget.data['user_info']['name']}',
                      style: kProductNameStyle,
                    ),
                  Text(
                    widget.isFromOrder
                        ? '${widget.data['customer_info']['mobile']}'
                        : '${widget.data['user_info']['mobile']}',
                    style: kProductNameStylePro,
                  ),
                  Text(
                    widget.isFromOrder
                        ? '${widget.data['customer_info']['address']}'
                        : '${widget.data['user_info']['address']}',
                    style: kProductNameStylePro,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ' QTY $quantity  Items ${items.length.toString()}',
                    style: kProductNameStylePro,
                  ),
                  const Text(
                    'Amount',
                    style: kProductNameStylePro,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int i) {
                      num unitPrice = widget.data['items'][i]['product_price'] /
                          widget.data['items'][i]['quantity'];
                      return ListTile(
                        leading: Text(
                          '${widget.data['items'][i]['quantity'].toString()} X',
                          style: kProductNameStylePro,
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.data['items'][i]['product_name']} (${widget.data['items'][i]['product_id']})',
                              style: kProductNameStylePro,
                            ),
                            Text(
                              unitPrice.toString(),
                              style: kProductNameStylePro,
                            ),
                          ],
                        ),
                        trailing: Text(
                            widget.data['items'][i]['product_price'].toString(),
                            style: kProductNameStylePro),
                      );
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    const Text(
                      'VAT: %',
                      style: kProductNameStylePro,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Discount: ${widget.data['discount'].toString()}',
                      style: kProductNameStylePro,
                    ),
                    Text(
                      'Sub Total: ${widget.data['price'].toString()}',
                      style: kProductNameStylePro,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Advance: ${widget.isFromOrder ? 0.toString() : widget.data['advance'].toString()}',
                      style: kProductNameStylePro,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Due: ${widget.isFromOrder ? 0.toString() : widget.data['due'].toString()}',
                      style: kProductNameStylePro,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Paid: ${widget.isFromOrder ? 0.toString() : widget.data['paid'].toString()}',
                      style: kProductNameStylePro,
                    ),
                  ]),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          color: kSubMainColor,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: IconButton(
                    onPressed: () {
                      Invoice().createPDF(
                        totalItems: quantity,
                        subTotal: widget.data['price'].toString(),
                        items: items,
                        mobile: widget.isFromOrder
                            ? '${widget.data['customer_info']['mobile']}'
                            : widget.data['user_info']['mobile'],
                        address: widget.isFromOrder
                            ? '${widget.data['customer_info']['address']}'
                            : widget.data['user_info']['address'],
                        name: widget.isFromOrder
                            ? '${widget.data['customer_info']['name']}'
                            : widget.data['user_info']['name'],
                        advance: widget.isFromOrder
                            ? '0'
                            : widget.data['advance'].toString(),
                        due: widget.isFromOrder
                            ? '0'
                            : widget.data['due'].toString(),
                        paid: widget.isFromOrder
                            ? '0'
                            : widget.data['paid'].toString(),
                        discountAmount: widget.isFromOrder
                            ? '0'
                            : widget.data['discount'].toString(),
                        invoiceId: widget.isFromOrder
                            ? widget.data['orderId']
                            : widget.data['invoice_id'],
                      );
                    },
                    icon: const Icon(Icons.save),
                    color: Colors.white,
                    iconSize: 40,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    onPressed: () {
                      shareInvoice(
                        date: DateFormat.yMMMd().format(date),
                        totalItems: quantity,
                        total: widget.data['data'].toString() ?? '0',
                        subTotal: widget.data['price'].toString(),
                        totalQuantity: quantity,
                        items: items,
                        mobile: widget.isFromOrder
                            ? '${widget.data['customer_info']['mobile']}'
                            : widget.data['user_info']['mobile'],
                        address: widget.isFromOrder
                            ? '${widget.data['customer_info']['address']}'
                            : widget.data['user_info']['address'],
                        name: widget.isFromOrder
                            ? '${widget.data['customer_info']['name']}'
                            : widget.data['user_info']['name'],
                        advance: widget.isFromOrder
                            ? '0'
                            : widget.data['advance'].toString(),
                        due: widget.isFromOrder
                            ? '0'
                            : widget.data['due'].toString(),
                        paid: widget.isFromOrder
                            ? '0'
                            : widget.data['paid'].toString(),
                        discountAmount: widget.isFromOrder
                            ? '0'
                            : widget.data['discount'].toString(),
                        invoiceId: widget.isFromOrder
                            ? widget.data['orderId']
                            : widget.data['invoice_id'],
                      );
                    },
                    icon: const Icon(Icons.share),
                    color: Colors.white,
                    iconSize: 40,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return BluetoothPrinter(
                              payList: const [],
                              isWithBusinessName: role != 'general',
                              businessName: widget.isFromOrder ? widget.data['customer_info']['business_name'] : widget.data['user_info']['business_name'],
                              quantity: quantity,
                              subTotal: widget.data['price'].toString(),
                              total: widget.data['price'].toString(),
                              items: items,
                              mobile: widget.isFromOrder
                                  ? '${widget.data['customer_info']['mobile']}'
                                  : widget.data['user_info']['mobile'],
                              address: widget.isFromOrder
                                  ? '${widget.data['customer_info']['address']}'
                                  : widget.data['user_info']['address'],
                              name: widget.isFromOrder
                                  ? '${widget.data['customer_info']['name']}'
                                  : widget.data['user_info']['name'],
                              advance: widget.isFromOrder
                                  ? '0'
                                  : widget.data['advance'].toString(),
                              due: widget.isFromOrder
                                  ? '0'
                                  : widget.data['due'].toString(),
                              paid: widget.isFromOrder
                                  ? '0'
                                  : widget.data['paid'].toString(),
                              discountAmount: widget.isFromOrder
                                  ? '0'
                                  : widget.data['discount'].toString(),
                              invoiceId: widget.isFromOrder
                                  ? widget.data['orderId']
                                  : widget.data['invoice_id'],
                              date: DateFormat.yMMMd().format(date),
                            );
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.print),
                    color: Colors.white,
                    iconSize: 40,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
