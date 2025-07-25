import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_bloc/transactions/barrel.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/boxes.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/functions.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/screens/due/due_receipt.dart';
import 'package:viraeshop_admin/screens/orders/order_tranz_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_api/models/transactions/transactions.dart';
import 'package:viraeshop_api/utils/utils.dart';

import '../../reusable_widgets/date/my_date_picker.dart';
import '../transactions/customer_transactions.dart';
import '../transactions/transaction_details.dart';

class DueScreen extends StatefulWidget {
  const DueScreen({Key? key}) : super(key: key);

  @override
  State<DueScreen> createState() => _DueScreenState();
}

class _DueScreenState extends State<DueScreen> {
  final TextEditingController invoiceController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  List customerInvoices = [];
  List invoiceBackup = [];
  num totalDue = 0;
  bool isLoading = false;
  bool dueCalculated = false;
  DateTime begin = DateTime.now();
  DateTime end = DateTime.now();
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(
        color: kMainColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          title: const Text(
            'Due',
            style: kAppBarTitleTextStyle,
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(FontAwesomeIcons.chevronLeft),
            iconSize: 20.0,
            color: kSubMainColor,
          ),
        ),
        body: BlocListener<TransactionsBloc, TransactionState>(
          listener: (context, state) {
            if (state is FetchedTransactionState) {
              final invoice = state.transactionModel;
              setState(() {
                isLoading = false;
                customerInvoices.add(invoice.toJson());
              });
            } else if (state is OnErrorTransactionState) {
              setState(() {
                isLoading = false;
              });
              snackBar(
                text: state.message,
                context: context,
                color: kRedColor,
                duration: 500,
              );
            } else if (state is FetchedTransactionsState) {
              List<Transactions>? invoices = state.transactionList;
              List fetchInvoices = [];
              for (var invoice in invoices) {
                fetchInvoices.add(invoice.toJson());
              }
              setState(() {
                isLoading = false;
                customerInvoices = fetchInvoices;
                invoiceBackup = customerInvoices;
              });
              if (state.message == 'No available Invoice') {
                toast(context: context, title: 'No available Invoice');
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            color: kBackgroundColor,
            height: screenSize.height,
            width: screenSize.width,
            child: Stack(
              //fit: StackFit.expand,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 190),
                    child: Column(
                      children: List.generate(customerInvoices.length, (i) {
                        List items = customerInvoices[i]['items'] ?? [];
                        String description = '';
                        for (var element in items) {
                          description +=
                              '${element['quantity']} X ${element['productName']}, ';
                        }
                        Timestamp timestamp =
                            dateFromJson(customerInvoices[i]['createdAt']);
                        String date =
                            DateFormat.yMMMd().format(timestamp.toDate());
                        return OrderTranzCard(
                          key: ValueKey(customerInvoices[i]['invoiceNo']),
                          price: customerInvoices[i]['price'].toString(),
                          employeeName: customerInvoices[i]['adminInfo']
                              ['name'],
                          desc: description,
                          date: date,
                          customerName: customerInvoices[i]['customerInfo']
                              ['name'],
                          id:
                              customerInvoices[i]['invoiceNo'].toString(),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DueReceipt(data: customerInvoices[i]),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 170,
                    color: kBackgroundColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            dateWidget(
                              borderColor: kSubMainColor,
                              color: kSubMainColor,
                              title: begin.toString().split(' ')[0],
                              onTap: () async {
                                final result = await myDatePicker(context);
                                setState(() {
                                  begin = result;
                                });
                              },
                            ),
                            const Icon(
                              Icons.arrow_forward,
                              color: kSubMainColor,
                              size: 20.0,
                            ),
                            dateWidget(
                                borderColor: kSubMainColor,
                                color: kSubMainColor,
                                onTap: () async {
                                  final result = await myDatePicker(context);
                                  setState(() {
                                    end = result;
                                  });
                                },
                                title: end.isAtSameMomentAs(DateTime.now())
                                    ? 'To this date..'
                                    : end.toString().split(' ')[0]),
                            const SizedBox(
                              width: 20.0,
                            ),
                            roundedTextButton(
                                borderColor: kSubMainColor,
                                textColor: kSubMainColor,
                                onTap: () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  final transactionBloc =
                                      BlocProvider.of<TransactionsBloc>(
                                          context);
                                  transactionBloc.add(
                                    SearchTransactionEvent(
                                      token: jWTToken,
                                      data: {
                                        'isDateSearch': true,
                                        'startDate': begin.toIso8601String(),
                                        'endDate': end.toIso8601String(),
                                      },
                                    ),
                                  );
                                }),
                            const SizedBox(
                              width: 20.0,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        SearchWidget(
                          controller: nameController,
                          onChanged: (value) async {
                            /**
                             * The first condition(1st): will check if the user wants to erase the previous
                             * search term, and enter a new search term or makes a mistake it will wipe out
                             * all the available data to give room for new incoming data(invoices)
                             *
                             * The second condition(2nd): will check to see if customerInvoice
                             * list(which is the main repo) is empty as a result of a spelling mistakes etc
                             * it will try to recover the list from the backup list
                             *
                             * The third condition(3rd): will check and see if the characters entered by the user
                             * are up to 3 and customerInvoice is empty then it will invoke the SearchTransactionEvent()
                             * to fetch the invoices from database
                             *
                             * The last condition(4th):  will check to see if the characters entered by the user is
                             * more than 3, and surely customerInvoices is not empty then it will search through the
                             * customerInvoices list.
                             *
                             */
                            if (value.isEmpty) {
                              setState(() {
                                customerInvoices.clear();
                                invoiceBackup.clear();
                              });
                            }
                            if (customerInvoices.isEmpty &&
                                invoiceBackup.isNotEmpty) {
                              setState(() {
                                customerInvoices = searchEngine(
                                    value: value,
                                    key: 'customerInfo',
                                    temps: invoiceBackup,
                                    isNested: true,
                                    key2: 'name',
                                    key3: 'businessName');
                                for (var invoice in customerInvoices) {
                                  totalDue += invoice['due'];
                                }
                              });
                            }
                            if (value.length == 2 && customerInvoices.isEmpty) {
                              setState(() {
                                isLoading = true;
                              });
                              final transactionBloc =
                                  BlocProvider.of<TransactionsBloc>(context);
                              transactionBloc.add(
                                SearchTransactionEvent(
                                  token: jWTToken,
                                  data: {
                                    'terms': value,
                                    'isDateSearch': false,
                                  },
                                ),
                              );
                            } else if (value.length > 2) {
                              setState(() {
                                customerInvoices = searchEngine(
                                    value: value,
                                    key: 'customerInfo',
                                    temps: invoiceBackup,
                                    isNested: true,
                                    key2: 'name',
                                    key3: 'businessName');
                                for (var invoice in customerInvoices) {
                                  totalDue += invoice['due'];
                                }
                              });
                            }
                          },
                          onSubmitted: (value) async {},
                          hintText: 'Search by name',
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        SearchWidget(
                          controller: invoiceController,
                          onSubmitted: (value) async {
                            if (nameController.text.isEmpty) {
                              setState(() {
                                customerInvoices.clear();
                                invoiceBackup.clear();
                              });
                            }
                            if (customerInvoices.isEmpty &&
                                invoiceBackup.isEmpty) {
                              setState(() {
                                isLoading = true;
                              });
                              final transactionBloc =
                                  BlocProvider.of<TransactionsBloc>(context);
                              transactionBloc.add(GetTransactionEvent(
                                  token: jWTToken, invoiceNo: value));
                            } else {
                              setState(() {
                                customerInvoices = searchEngine(
                                    value: value,
                                    key: 'invoiceNo',
                                    temps: invoiceBackup);
                              });
                            }
                          },
                          hintText: 'Search by invoice number',
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 45,
                    decoration: const BoxDecoration(
                      color: kBackgroundColor,
                      border: Border(
                        top: BorderSide(color: kSubMainColor),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Total Due: -${totalDue.toString() + bdtSign}',
                        style: kDueCellStyle,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchWidget extends StatelessWidget {
  const SearchWidget(
      {Key? key,
      required this.controller,
      required this.onSubmitted,
      required this.hintText,
      this.onChanged})
      : super(key: key);
  final void Function(String value)? onSubmitted;
  final void Function(String value)? onChanged;
  final TextEditingController controller;
  final String hintText;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: kBackgroundColor,
        border: Border.all(
          color: kSubMainColor,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextField(
        controller: controller,
        cursorColor: kSubMainColor,
        style: kProductNameStylePro,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: kProductNameStylePro,
          focusedBorder: const OutlineInputBorder(),
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
