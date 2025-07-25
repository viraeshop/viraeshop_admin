import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_bloc/transactions/barrel.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/functions.dart';
import 'package:viraeshop_admin/configs/share_invoice.dart';
import 'package:viraeshop_admin/printer/bluetooth_printer.dart';
import 'package:viraeshop_admin/reusable_widgets/buttons/round_button.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_api/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_bloc/viraeshop_bloc.dart';

import '../../components/ui_components/delete_popup.dart';
import '../../configs/boxes.dart';

enum WalletAction {
  add,
  subtract,
  none,
}

class DueReceipt extends StatefulWidget {
  final Map data;
  final String title;
  final bool isOnlyShow;
  final bool isNeedRefresh;
  final String fromWho;
  final String userId;
  const DueReceipt({
    required this.data,
    this.title = 'Due Receipt',
    this.isOnlyShow = false,
    this.isNeedRefresh = false,
    this.fromWho = 'customer',
    this.userId = '',
    Key? key,
  }) : super(key: key);
  @override
  _DueReceiptState createState() => _DueReceiptState();
}

class _DueReceiptState extends State<DueReceipt> {
  DateTime date = DateTime.now();
  List items = [];
  List<bool> isEditItem = [];
  String quantity = '0';
  final TextEditingController payController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  bool isEditing = false;
  bool isLoading = false;
  bool isDiscount = false;
  num due = 0,
      paid = 0,
      discount = 0,
      subTotal = 0,
      total = 0,
      walletActionAmount = 0;
  List payList = [];
  List newPayList = [];
  String role = '';
  static Timestamp timestamp = Timestamp.now();
  static final formatter = DateFormat('MM/dd/yyyy');
  String dateTime = formatter.format(
    timestamp.toDate(),
  );
  WalletAction walletAction = WalletAction.none;
  final jWTToken = Hive.box('adminInfo').get('token');
  bool isManageDue = Hive.box('adminInfo').get('isManageDue');
  Map<String, dynamic> customerInfo = {};
  @override
  void initState() {
    customerInfo = widget.data['customerInfo'] ?? {};
    List item = widget.data['items'];
    Timestamp timestamp = dateFromJson(widget.data['createdAt']);
    num totalQuantity = 0;
    for (var element in item) {
      totalQuantity += element['quantity'];
    }
    date = timestamp.toDate();
    items = item.toList();
    isEditItem = List.generate(items.length, (index) => false);
    quantity = totalQuantity.toString();
    due = widget.data['due'];
    paid = widget.data['paid'];
    payList = widget.data['payList'] ?? [];
    role = widget.data['role'];
    discount = widget.data['discount'];
    subTotal = widget.data['price'];
    total = widget.data['price'] + (widget.data['discount'] ?? 0);
    super.initState();
  }

  @override
  void dispose() {
    payController.dispose();
    discountController.dispose();
    super.dispose();
  }

  bool onEdit = false;
  Map<String, dynamic> editedInvoice = {};
  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomersBloc, CustomerState>(
      listener: (context, state) {
        if (state is RequestFinishedCustomerState) {
          setState(() {
            if (walletAction == WalletAction.subtract) {
              customerInfo['wallet'] -= walletActionAmount;
              customerInfo['dueBalance'] += walletActionAmount;
            } else if (walletAction == WalletAction.add) {
              customerInfo['wallet'] += walletActionAmount;
              customerInfo['dueBalance'] -= walletActionAmount;
            }
            isLoading = false;
            onEdit = true;
            walletAction = WalletAction.none;
            walletActionAmount = 0;
            editedInvoice.clear();
          });
          toast(
            context: context,
            title: state.response.message,
          );
        } else if (state is OnErrorCustomerState) {
          setState(() {
            isLoading = false;
          });
          snackBar(
            text: state.message,
            context: context,
            color: kRedColor,
            duration: 50,
          );
        }
      },
      child: BlocListener<TransactionsBloc, TransactionState>(
        listenWhen: (context, state) {
          if (state is RequestFinishedTransactionState ||
              state is OnErrorTransactionState) {
            return true;
          } else {
            return false;
          }
        },
        listener: (context, state) {
          if (state is RequestFinishedTransactionState) {
            List deletedItems = editedInvoice['deletedItems'] ?? [];
            if (deletedItems.isNotEmpty) {
              List products = Hive.box(productsBox).get(productsKey);
              for (var item in deletedItems) {
                if (item['isInventory']) {
                  final itemId = item['productId'];
                  for (var product in products) {
                    if (product['productId'] == itemId &&
                        !product['isInfinity']) {
                      int quantity = product['quantity'] + item['quantity'];
                      product['quantity'] = quantity;
                    }
                  }
                }
              }
              Hive.box(productsBox).put(productsKey, products);
            }
            if (walletAction == WalletAction.subtract) {
              final customerBloc = BlocProvider.of<CustomersBloc>(context);
              customerBloc.add(UpdateCustomerEvent(
                customerId: customerInfo['customerId'],
                token: jWTToken,
                customerModel: {
                  'wallet': customerInfo['wallet'] - walletActionAmount,
                  'dueBalance': customerInfo['dueBalance'] + walletActionAmount,
                },
              ));
            } else if (walletAction == WalletAction.add) {
              final customerBloc = BlocProvider.of<CustomersBloc>(context);
              customerBloc.add(UpdateCustomerEvent(
                customerId: customerInfo['customerId'],
                token: jWTToken,
                customerModel: {
                  'wallet': customerInfo['wallet'] + walletActionAmount,
                  'dueBalance': customerInfo['dueBalance'] - walletActionAmount,
                },
              ));
            }
          } else if (state is OnErrorTransactionState) {
            setState(() {
              isLoading = false;
            });
            snackBar(
              text: state.message,
              context: context,
              color: kRedColor,
              duration: 50,
            );
          }
        },
        child: ModalProgressHUD(
          inAsyncCall: isLoading,
          progressIndicator: const CircularProgressIndicator(
            color: kNewMainColor,
          ),
          child: Scaffold(
            backgroundColor: kBackgroundColor,
            appBar: AppBar(
              leading: IconButton(
                  onPressed: () {
                    if (widget.isNeedRefresh && onEdit) {
                      final transactionBloc =
                          BlocProvider.of<TransactionsBloc>(context);
                      transactionBloc.add(GetTransactionsEvent(
                        token: jWTToken,
                        queryType: widget.fromWho,
                        id: widget.data['customerInfo']['customerId'],
                      ));
                    }
                    Navigator.pop(context);
                  },
                  icon: const Icon(FontAwesomeIcons.chevronLeft)),
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
                IconButton(
                  onPressed: isManageDue
                      ? () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return DeletePopup(
                                  onDelete: () async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    Navigator.pop(context);
                                    final transactionBloc =
                                        BlocProvider.of<TransactionsBloc>(
                                            context);
                                    transactionBloc.add(
                                      DeleteTransactionEvent(
                                        token: jWTToken,
                                        invoiceNo: widget.data['invoiceNo'],
                                      ),
                                    );
                                  },
                                );
                              });
                        }
                      : null,
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
                        height: 150.0,
                        width: double.infinity,
                        child: Image.asset('assets/invoice_logo.png'),
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
                        'Invoice No ${widget.data['channel'] == 'mobile_app' && widget.data['orderId'] != null ? widget.data['orderId'] : widget.data['invoiceNo']}',
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
                          '${widget.data['customerInfo']['businessName']}',
                          style: kProductNameStyle,
                        ),
                      Text(
                        '${widget.data['customerInfo']['name']}',
                        style: kProductNameStyle,
                      ),
                      Text(
                        '${widget.data['customerInfo']['mobile']}',
                        style: kProductNameStylePro,
                      ),
                      Text(
                        '${widget.data['customerInfo']['address']}',
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
                    padding: const EdgeInsets.only(
                        left: 0.0, top: 10.0, bottom: 10.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int i) {
                          num unitPrice = items[i]['unitPrice'];
                          return Row(children: [
                            Column(
                              children: [
                                TextButton(
                                  onPressed: isManageDue
                                      ? () {
                                          if (walletAction ==
                                              WalletAction.none) {
                                            setState(() {
                                              isEditItem[i] = !isEditItem[i];
                                              if (!isEditItem[i]) {
                                                walletAction =
                                                    WalletAction.none;
                                                walletActionAmount = 0;
                                              }
                                            });
                                          } else {
                                            showToast(
                                              'Please update the invoice first, you have not completed the previous action.',
                                              context: context,
                                              backgroundColor: kRedColor,
                                            );
                                          }
                                        }
                                      : null,
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
                                            items[i]['productPrice'] +=
                                                unitPrice;
                                            subTotal += unitPrice;
                                            total += unitPrice;
                                            due += unitPrice;
                                            walletActionAmount += unitPrice;
                                            walletAction =
                                                WalletAction.subtract;
                                            if (editedInvoice['editedItems'] ==
                                                null) {
                                              editedInvoice['editedItems'] = [
                                                items[i]
                                              ];
                                            } else {
                                              List onEditItems =
                                                  editedInvoice['editedItems'];
                                              int index = getItemIndex(
                                                  onEditItems, items[i]);
                                              if (index == -1) {
                                                onEditItems.add(items[i]);
                                              } else {
                                                onEditItems[index] = items[i];
                                              }
                                              editedInvoice['editedItems'] =
                                                  onEditItems;
                                            }
                                            editedInvoice['due'] = due;
                                            editedInvoice['price'] = subTotal;
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
                                              items[i]['productPrice'] -=
                                                  unitPrice;
                                              subTotal -= unitPrice;
                                              total -= unitPrice;
                                              walletActionAmount += unitPrice;
                                              walletAction = WalletAction.add;
                                              if (due != 0) {
                                                due -= unitPrice;
                                              } else if (due - unitPrice < 0) {
                                                due = 0;
                                              }
                                              editedInvoice['due'] = due;
                                              editedInvoice['price'] = subTotal;
                                              if (editedInvoice[
                                                      'editedItems'] ==
                                                  null) {
                                                editedInvoice['editedItems'] = [
                                                  items[i]
                                                ];
                                              } else {
                                                List onEditItems =
                                                    editedInvoice[
                                                        'editedItems'];
                                                int index = getItemIndex(
                                                    onEditItems, items[i]);
                                                if (index == -1) {
                                                  onEditItems.add(items[i]);
                                                } else {
                                                  onEditItems[index] = items[i];
                                                }
                                                editedInvoice['editedItems'] =
                                                    onEditItems;
                                              }
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
                                    '${items[i]['productName']} (${items[i]['productId']})',
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
                                    '${items[i]['productPrice']}$bdtSign'
                                        .toString(),
                                    style: kProductNameStylePro),
                                const SizedBox(
                                  width: 5.0,
                                ),
                                IconButton(
                                  onPressed: isManageDue
                                      ? () async {
                                          if (walletAction ==
                                              WalletAction.none) {
                                            setState(() {
                                              onEdit = true;
                                            });
                                            if (editedInvoice['deletedItems'] ==
                                                null) {
                                              editedInvoice['deletedItems'] = [
                                                items[i]
                                              ];
                                            } else {
                                              editedInvoice['deletedItems']
                                                  .add(items[i]);
                                            }
                                            setState(() {
                                              subTotal -=
                                                  items[i]['productPrice'];
                                              total -= items[i]['productPrice'];
                                              if (due != 0) {
                                                due -= items[i]['productPrice'];
                                              } else if ((due -
                                                      items[i]
                                                          ['productPrice']) <
                                                  0) {
                                                due = 0;
                                              }
                                              editedInvoice['due'] = due;
                                              editedInvoice['price'] = subTotal;
                                              walletActionAmount =
                                                  items[i]['productPrice'];
                                              walletAction = WalletAction.add;
                                              items.removeAt(i);
                                            });
                                          } else {
                                            showToast(
                                              'Please update the invoice first, you have not completed the previous action.',
                                              context: context,
                                              backgroundColor: kRedColor,
                                            );
                                          }
                                        }
                                      : null,
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
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'VAT: %',
                              style: kProductNameStylePro,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Total: $total',
                              style: kProductNameStylePro,
                            ),
                            //const SizedBox(height: 5),
                            if (isDiscount && !widget.isOnlyShow && isManageDue)
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
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        if (walletAction == WalletAction.none) {
                                          setState(() {
                                            discount = discountController
                                                    .text.isNotEmpty
                                                ? num.parse(
                                                    discountController.text)
                                                : discount;
                                            subTotal -= discount;
                                            if (due != 0) {
                                              due -= discount;
                                            } else if (due - discount < 0) {
                                              due = 0;
                                            }
                                            editedInvoice['discount'] =
                                                discount;
                                            editedInvoice['due'] = due;
                                            walletActionAmount = discount;
                                            walletAction = WalletAction.add;
                                            isDiscount = false;
                                          });
                                        } else {
                                          showToast(
                                            'Please update the invoice first, you have not completed the previous action.',
                                            context: context,
                                            backgroundColor: kRedColor,
                                          );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.done,
                                        color: kNewMainColor,
                                      ),
                                      iconSize: 20.0,
                                      //color: kNewMainColor,
                                    ),
                                    suffixIconColor: kNewMainColor,
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
                              )
                            else
                              TextButton(
                                onPressed: () {
                                  if (walletAction == WalletAction.none) {
                                    setState(() {
                                      isDiscount = true;
                                    });
                                  } else {
                                    showToast(
                                      'Please update the invoice first, you have not completed the previous action.',
                                      context: context,
                                      backgroundColor: kRedColor,
                                    );
                                  }
                                },
                                child: Text(
                                  'Discount: ${discount.toString()}',
                                  style: kProductNameStylePro,
                                ),
                              ),
                            //const SizedBox(height: 5),
                            Text(
                              'Sub Total: ${subTotal.toString()}',
                              style: kProductNameStylePro,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Advance: ${widget.data['advance'].toString()}',
                              style: kProductNameStylePro,
                            ),
                            const SizedBox(height: 5),
                            if (payList.isNotEmpty)
                              Column(
                                children:
                                    List.generate(payList.length, (index) {
                                  Timestamp timestamp =
                                      dateFromJson(payList[index]['createdAt']);
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
                                      onPressed: isManageDue
                                          ? () {
                                              if (walletAction ==
                                                  WalletAction.none) {
                                                setState(() {
                                                  isEditing = true;
                                                });
                                              } else {
                                                showToast(
                                                  'Please update the invoice first, you have not completed the previous action.',
                                                  context: context,
                                                  backgroundColor: kRedColor,
                                                );
                                              }
                                            }
                                          : null,
                                      child: Text(
                                        'Pay: ${payController.text}',
                                        style: kProductNameStylePro,
                                      ),
                                    )
                                  else if (!widget.isOnlyShow)
                                    SizedBox(
                                      width: 150.0,
                                      child: TextField(
                                        controller: payController,
                                        style: kProductNameStylePro,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              // Check if the payController is not empty
                                              if (payController
                                                  .text.isNotEmpty) {
                                                final pay = num.parse(
                                                    payController
                                                            .text.isNotEmpty
                                                        ? payController.text
                                                        : '0');
                                                // Check if the pay is less than or equal to due
                                                if (pay <= due) {
                                                  // Update the state with the new values
                                                  setState(() {
                                                    isEditing = false;
                                                  });
                                                  // Add the payment to the payList and update the invoice
                                                  List newPayList =
                                                      payList.toList();
                                                  setState(() {
                                                    due -= pay;
                                                    payList.add({
                                                      'createdAt': dateToJson(
                                                          Timestamp.now()),
                                                      'paid': pay,
                                                      'isSupplier': false,
                                                      'invoiceNo': widget
                                                          .data['invoiceNo'],
                                                    });
                                                    newPayList.add({
                                                      'createdAt': dateToJson(
                                                          Timestamp.now()),
                                                      'paid': pay,
                                                      'isSupplier': false,
                                                      'invoiceNo': widget
                                                          .data['invoiceNo'],
                                                    });
                                                    if (payController.text !=
                                                        '0') {
                                                      paid += pay;
                                                    }
                                                    editedInvoice['paid'] =
                                                        paid;
                                                    editedInvoice['payList'] =
                                                        newPayList;
                                                    editedInvoice['due'] = due;
                                                    walletActionAmount = pay;
                                                    walletAction =
                                                        WalletAction.add;
                                                    isEditing = false;
                                                  });
                                                } else {
                                                  // Show a toast if the pay is greater than due
                                                  showToast(
                                                    'Amount cannot be greater than due',
                                                    context: context,
                                                    backgroundColor: kRedColor,
                                                  );
                                                  return;
                                                }
                                              } else {
                                                showToast(
                                                  'Please enter a valid amount',
                                                  context: context,
                                                  backgroundColor: kRedColor,
                                                );
                                                return;
                                              }
                                            },
                                            icon: const Icon(Icons.done),
                                            iconSize: 20.0,
                                          ),
                                          suffixIconColor: kNewMainColor,
                                          border: const UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: kSubMainColor),
                                          ),
                                          focusedBorder:
                                              const UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: kNewMainColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            const SizedBox(height: 5),
                            Text(
                              'Due: ${due.toString()}',
                              style: kProductNameStylePro,
                            ),
                            const SizedBox(height: 5),
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
            bottomNavigationBar: SafeArea(
              child: Container(
                color: kSubMainColor,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          onPressed: () async {
                            try {
                              await shareInvoice(
                                isSave: true,
                                totalItems: items.length.toString(),
                                totalQuantity: quantity,
                                subTotal: subTotal.toString(),
                                total: total,
                                items: items,
                                mobile: widget.data['customerInfo']['mobile'],
                                address: widget.data['customerInfo']['address'],
                                name: role == 'general'
                                    ? widget.data['customerInfo']['name']
                                    : '${widget.data['customerInfo']['businessName']}(${widget.data['customerInfo']['name']})',
                                advance: widget.data['advance'].toString(),
                                due: due.toString(),
                                paid: paid.toString(),
                                discountAmount: discount.toString(),
                                invoiceId:
                                    widget.data['channel'] == 'mobile_app' &&
                                            widget.data['orderId'] != null
                                        ? widget.data['orderId'].toString()
                                        : widget.data['invoiceNo'].toString(),
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
                          onPressed: () async {
                            try {
                              await shareInvoice(
                                totalItems: items.length.toString(),
                                totalQuantity: quantity,
                                subTotal: subTotal.toString(),
                                total: total,
                                items: items,
                                mobile: widget.data['customerInfo']['mobile'],
                                address: widget.data['customerInfo']['address'],
                                name: role == 'general'
                                    ? widget.data['customerInfo']['name']
                                    : '${widget.data['customerInfo']['businessName']}(${widget.data['customerInfo']['name']})',
                                advance: widget.data['advance'].toString(),
                                due: due.toString(),
                                paid: paid.toString(),
                                discountAmount: discount.toString(),
                                invoiceId:
                                    widget.data['channel'] == 'mobile_app' &&
                                            widget.data['orderId'] != null
                                        ? widget.data['orderId'].toString()
                                        : widget.data['invoiceNo'].toString(),
                                date: DateFormat.yMMMd().format(date),
                                payList: payList,
                              );
                            } catch (e) {
                              debugPrint(e.toString());
                            }
                          },
                          icon: const Icon(Icons.share),
                          color: Colors.white,
                          iconSize: 40,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          onPressed: isManageDue
                              ? () {
                                  setState(() {
                                    isLoading = true;
                                    onEdit = true;
                                  });
                                  debugPrint(editedInvoice.toString());
                                  final transacBloc =
                                      BlocProvider.of<TransactionsBloc>(
                                          context);
                                  transacBloc.add(
                                    UpdateTransactionEvent(
                                      token: jWTToken,
                                      transactionModel: editedInvoice,
                                      invoiceNo:
                                          widget.data['invoiceNo'].toString(),
                                    ),
                                  );
                                }
                              : null,
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
                                    date: DateFormat.yMMMd().format(date),
                                    payList: payList,
                                    isWithBusinessName: role != 'general',
                                    businessName: widget.data['customerInfo']
                                            ['businessName'] ??
                                        '',
                                    quantity: quantity,
                                    subTotal: subTotal.toString(),
                                    total: widget.data['price'].toString(),
                                    items: items,
                                    mobile: widget.data['customerInfo']
                                        ['mobile'],
                                    address: widget.data['customerInfo']
                                        ['address'],
                                    name: widget.data['customerInfo']['name'],
                                    advance: widget.data['advance'].toString(),
                                    due: widget.data['due'].toString(),
                                    paid: widget.data['paid'].toString(),
                                    discountAmount:
                                        widget.data['discount'].toString(),
                                    invoiceId: widget.data['channel'] ==
                                                'mobile_app' &&
                                            widget.data['orderId'] != null
                                        ? widget.data['orderId'].toString()
                                        : widget.data['invoiceNo'].toString(),
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
          ),
        ),
      ),
    );
  }
}
