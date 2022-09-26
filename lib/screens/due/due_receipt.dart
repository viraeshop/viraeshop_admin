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
import 'package:viraeshop_admin/reusable_widgets/buttons/round_button.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';

import '../../components/ui_components/delete_popup.dart';
import '../../configs/baxes.dart';
import '../transactions/non_inventory_transaction_info.dart';

class DueReceipt extends StatefulWidget {
  final Map data;
  final String title;
  final bool isOnlyShow;
  const DueReceipt(
      {required this.data,
      this.title = 'Due Receipt',
      this.isOnlyShow = false});
  @override
  _DueReceiptState createState() => _DueReceiptState();
}

class _DueReceiptState extends State<DueReceipt> {
  DateTime date = DateTime.now();
  List items = [];
  List<bool> isEditItem = [];
  String quantity = '0';
  final TextEditingController controller = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  bool isEditing = false;
  bool isLoading = false;
  bool isDiscount = false;
  num due = 0, paid = 0, discount = 0, subTotal = 0;
  List payList = [];
  String role = '';
  static Timestamp timestamp = Timestamp.now();
  static final formatter = DateFormat('MM/dd/yyyy');
  String dateTime = formatter.format(
    timestamp.toDate(),
  );
  @override
  void initState() {
    // TODO: implement initState
    List item = widget.data['items'];
    Timestamp timestamp = widget.data['date'];
    num totalQuantity = 0;
    for (var element in item) {
      totalQuantity += element['quantity'];
    }
    date = timestamp.toDate();
    items = item;
    isEditItem = List.generate(items.length, (index) => false);
    quantity = totalQuantity.toString();
    due = widget.data['due'];
    print('due: $due');
    paid = widget.data['paid'];
    payList = widget.data['pay_list'] ?? [];
    role = widget.data['customer_role'];
    discount = widget.data['discount'];
    subTotal = widget.data['price'];
    super.initState();
  }

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
            widget.title,
            style: kAppBarTitleTextStyle,
          ),
          centerTitle: true,
          titleTextStyle: kTextStyle1,
          actions: [
            if (isManageDue)
              IconButton(
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
                                  widget.data['invoice_id']);
                              await NetworkUtility.updateProducts(items, true);
                              List products =
                                  Hive.box(productsBox).get(productsKey);
                              for (var item in items) {
                                if (item['isInventory']) {
                                  final itemId = item['product_id'];
                                  for (var product in products) {
                                    if (product['productId'] == itemId) {
                                      int quantity = product['quantity'] +
                                          item['quantity'];
                                      product['quantity'] = quantity;
                                    }
                                  }
                                }
                              }
                              Hive.box(productsBox).put(productsKey, products);
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
                    'Invoice No ${widget.data['invoice_id']}',
                    style: kProductNameStyle,
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (role != 'general')
                    Text(
                      '${widget.data['user_info']['business_name']}',
                      style: kProductNameStyle,
                    ),
                  Text(
                    '${widget.data['user_info']['name']}',
                    style: kProductNameStyle,
                  ),
                  Text(
                    '${widget.data['user_info']['mobile']}',
                    style: kProductNameStylePro,
                  ),
                  Text(
                    '${widget.data['user_info']['address']}',
                    style: kProductNameStylePro,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${items.length.toString()} Items (QTY $quantity)',
                    style: kProductNameStylePro,
                  ),
                  const Text(
                    'Amount',
                    style: kProductNameStylePro,
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 0.0, top: 10.0, bottom: 10.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int i) {
                      num unitPrice = items[i]['unit_price'];
                      return Row(children: [
                        Column(
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isEditItem[i] = !isEditItem[i];
                                });
                              },
                              child: Text(
                                '${items[i]['quantity'].toString()} X',
                                style: kProductNameStylePro,
                              ),
                            ),
                            if (isEditItem[i])
                              Row(
                                children: [
                                  RoundButton(
                                    onPressed: () {
                                      setState(() {
                                        items[i]['quantity'] += 1;
                                        subTotal -= items[i]['product_price'];
                                        items[i]['product_price'] =
                                            unitPrice * items[i]['quantity'];
                                        subTotal += items[i]['product_price'];
                                      });
                                    },
                                    icon: Icons.add,
                                    color: kNewMainColor,
                                    size: 20.0,
                                  ),
                                  RoundButton(
                                    onPressed: () {
                                      setState(() {
                                        if (items[i][quantity] != 0) {
                                          items[i]['quantity'] -= 1;
                                          subTotal -= items[i]['product_price'];
                                          items[i]['product_price'] =
                                              unitPrice * items[i]['quantity'];
                                          subTotal += items[i]['product_price'];
                                        }
                                      });
                                    },
                                    icon: Icons.remove,
                                    color: kNewMainColor,
                                    size: 20.0,
                                  ),
                                ],
                              ),
                          ],
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${items[i]['product_name']} (${items[i]['product_id']})',
                                style: kProductNameStylePro,
                                softWrap: true,
                              ),
                              Text(
                                '${unitPrice.toString()}$bdtSign',
                                style: kProductNameStylePro,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Row(
                          children: [
                            Text(
                                '${items[i]['product_price']}$bdtSign'
                                    .toString(),
                                style: kProductNameStylePro),
                            const SizedBox(
                              width: 5.0,
                            ),
                            IconButton(
                              onPressed: () async {
                                try {
                                  await NetworkUtility.updateProducts(
                                      items, true);
                                  List products =
                                      Hive.box(productsBox).get(productsKey);
                                  for (var item in items) {
                                    if (item['isInventory']) {
                                      final itemId = item['product_id'];
                                      for (var product in products) {
                                        if (product['productId'] == itemId) {
                                          int quantity = product['quantity'] +
                                              item['quantity'];
                                          product['quantity'] = quantity;
                                        }
                                      }
                                    }
                                  }
                                  Hive.box(productsBox)
                                      .put(productsKey, products);
                                  setState(() {
                                    subTotal -= items[i]['product_price'];
                                    items.removeAt(i);
                                  });
                                } on FirebaseException catch (e) {
                                  if (kDebugMode) {
                                    print(e.message);
                                  }
                                }
                              },
                              icon: const Icon(Icons.delete),
                              iconSize: 20.0,
                              color: kRedColor,
                            ),
                          ],
                        ),
                      ]);
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
                    if (isDiscount && !widget.isOnlyShow)
                      SizedBox(
                        width: 150.0,
                        child: TextField(
                          controller: discountController,
                          style: kProductNameStylePro,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              setState(() {
                                subTotal = widget.data['price'];
                                due = widget.data['due'];
                              });
                            }
                          },
                          decoration: InputDecoration(
                            suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  discount = discountController.text.isNotEmpty
                                      ? num.parse(discountController.text)
                                      : discount;
                                  subTotal -= discount;
                                  due -= discount;
                                  isDiscount = false;
                                });
                              },
                              icon: const Icon(Icons.done),
                              iconSize: 20.0,
                              color: kNewMainColor,
                            ),
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(color: kSubMainColor),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: kNewMainColor),
                            ),
                          ),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isDiscount = true;
                          });
                        },
                        child: Text(
                          'Discount: ${discount.toString()}',
                          style: kProductNameStylePro,
                        ),
                      ),
                    Text(
                      'Sub Total: ${subTotal.toString()}',
                      style: kProductNameStylePro,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Advance: ${widget.data['advance'].toString()}',
                      style: kProductNameStylePro,
                    ),
                    const SizedBox(height: 10),
                    if (payList.isNotEmpty)
                      Column(
                        children: List.generate(payList.length, (index) {
                          Timestamp timestamp = payList[index]['date'];
                          final formatter = DateFormat('MM/dd/yyyy');
                          String dateTime = formatter.format(
                            timestamp.toDate(),
                          );
                          return Row(
                            children: [
                              Text(
                                dateTime,
                                style: kProductNameStylePro,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Pay ${payList[index]['paid']}',
                                style: kProductNameStylePro,
                              ),
                            ],
                          );
                        }),
                      ),
                    if (due != 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!isEditing && !widget.isOnlyShow)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isEditing = true;
                                });
                              },
                              child: Text(
                                'Pay: ${controller.text}',
                                style: kProductNameStylePro,
                              ),
                            )
                          else if (!widget.isOnlyShow)
                            SizedBox(
                              width: 150.0,
                              child: TextField(
                                controller: controller,
                                style: kProductNameStylePro,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  suffix: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        due -= num.parse(
                                            controller.text.isNotEmpty
                                                ? controller.text
                                                : '0');
                                        payList.add({
                                          'date': Timestamp.now(),
                                          'paid':
                                              num.parse(controller.text ?? '0'),
                                        });
                                        if (controller.text != '0') {
                                          paid += num.parse(controller.text);
                                        }
                                        isEditing = false;
                                      });
                                    },
                                    icon: const Icon(Icons.done),
                                    iconSize: 20.0,
                                    color: kNewMainColor,
                                  ),
                                  border: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: kSubMainColor),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: kNewMainColor),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    Text(
                      'Due: ${due.toString()}',
                      style: kProductNameStylePro,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Paid: ${paid.toString()}',
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
                      try {
                        shareInvoice(
                          isSave: true,
                          totalItems: items.length.toString(),
                          totalQuantity: quantity,
                          subTotal: subTotal.toString(),
                          items: items,
                          mobile: widget.data['user_info']['mobile'],
                          address: widget.data['user_info']['address'],
                          name: role == 'general'
                              ? widget.data['user_info']['name']
                              : '${widget.data['user_info']['business_name']}(${widget.data['user_info']['name']})',
                          advance: widget.data['advance'].toString(),
                          due: due.toString(),
                          paid: paid.toString(),
                          discountAmount: discount.toString(),
                          invoiceId: widget.data['invoice_id'],
                          date: DateFormat.yMMMd().format(date),
                          payList: payList,
                        );
                        toast(context: context, title: 'Saved');
                      } catch (e) {
                        if (kDebugMode) {
                          print(e);
                        }
                      }
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
                        totalItems: items.length.toString(),
                        totalQuantity: quantity,
                        subTotal: subTotal.toString(),
                        items: items,
                        mobile: widget.data['user_info']['mobile'],
                        address: widget.data['user_info']['address'],
                        name: role == 'general'
                            ? widget.data['user_info']['name']
                            : '${widget.data['user_info']['business_name']} (${widget.data['user_info']['name']})',
                        advance: widget.data['advance'].toString(),
                        due: due.toString(),
                        paid: paid.toString(),
                        discountAmount: discount.toString(),
                        invoiceId: widget.data['invoice_id'],
                        date: DateFormat.yMMMd().format(date),
                        payList: payList,
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
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        await NetworkUtility.updateCustomerDue(
                            widget.data['invoice_id'], {
                          'price': subTotal,
                          'discount': discount,
                          'due': due,
                          'pay_list': payList,
                          'paid': paid,
                          'items': items,
                        });
                      } catch (e) {
                        if (kDebugMode) {
                          print(e);
                        }
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    icon: const Icon(Icons.update),
                    iconSize: 40.0,
                    color: kBackgroundColor,
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
                              payList: payList,
                              isWithBusinessName: role != 'general',
                              businessName: widget.data['user_info']
                                      ['business_name'] ??
                                  '',
                              quantity: quantity,
                              subTotal: widget.data['price'].toString(),
                              items: items,
                              mobile: widget.data['user_info']['mobile'],
                              address: widget.data['user_info']['address'],
                              name: widget.data['user_info']['name'],
                              advance: widget.data['advance'].toString(),
                              due: widget.data['due'].toString(),
                              paid: widget.data['paid'].toString(),
                              discountAmount:
                                  widget.data['discount'].toString(),
                              invoiceId: widget.data['invoice_id'],
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
