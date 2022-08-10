import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/baxes.dart';
import 'package:viraeshop_admin/configs/functions.dart';
import 'package:viraeshop_admin/screens/due/due_receipt.dart';
import 'package:viraeshop_admin/screens/orders/order_tranz_card.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';

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
        body: Container(
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
                  padding: const EdgeInsets.only(top: 120),
                  child: Column(
                    children: List.generate(customerInvoices.length, (i) {
                      List items = customerInvoices[i]['items'] ?? [];
                      String description = '';
                      for (var element in items) {
                        description +=
                            '${element['quantity']} X ${element['product_name']}, ';
                      }
                      Timestamp timestamp = customerInvoices[i]['date'];
                      String date =
                          DateFormat.yMMMd().format(timestamp.toDate());
                      return OrderTranzCard(
                        price: customerInvoices[i]['price'].toString(),
                        employeeName: customerInvoices[i]['employee_name'],
                        desc: description,
                        date: date,
                        customerName: customerInvoices[i]['user_info']['name'],
                        invoiceId: customerInvoices[i]['invoice_id'],
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
                  height: 120,
                  color: kBackgroundColor,
                  child: Column(
                    children: [
                      SearchWidget(
                        controller: nameController,
                        onChanged: (value) async{
                          if(value.isEmpty){
                            setState(() {
                              customerInvoices.clear();
                              invoiceBackup.clear();
                            });
                          }
                          if (customerInvoices.isEmpty && invoiceBackup.isNotEmpty) {
                            setState(() {
                              customerInvoices = searchEngine(value: value, key: 'user_info', temps: invoiceBackup, isNested: true, key2: 'name', key3: 'business_name');
                              for (var invoice in customerInvoices){
                                totalDue += invoice['due'];
                              }
                            });
                          }
                          if(value.length == 1 && customerInvoices.isEmpty){
                            setState(() {
                              isLoading = true;
                            });
                            try {
                              final invoices = await NetworkUtility
                                  .getCustomerTransactionInvoices(value.toUpperCase().characters.toList());
                              List fetchInvoices = [];
                              for (var invoice in invoices.docs) {
                                fetchInvoices.add(invoice.data());
                              }
                              setState(() {
                                customerInvoices = fetchInvoices;
                                invoiceBackup = customerInvoices;
                              });
                            } catch (e) {
                              if (kDebugMode) {
                                print(e);
                              }
                            }finally{
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }else if(value.length > 1){
                            setState((){
                              customerInvoices = searchEngine(value: value, key: 'user_info', temps: invoiceBackup, isNested: true, key2: 'name', key3: 'business_name');
                              for (var invoice in customerInvoices){
                                totalDue += invoice['due'];
                              }
                            });
                          }
                        },
                        onSubmitted: (value) async {
                        },
                        hintText: 'Search by name',
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      SearchWidget(
                        controller: invoiceController,
                        onSubmitted: (value) async{
                          if(customerInvoices.isEmpty && invoiceBackup.isEmpty){
                            setState(() {
                              isLoading = true;
                            });
                            try{
                              final transactionData = await NetworkUtility.getCustomerTransactionInvoicesByID(value);
                              setState(() {
                                if(transactionData.exists){
                                  customerInvoices.add(transactionData.data());
                                }
                              });
                            } on FirebaseException catch (e){
                              if(kDebugMode){
                                print(e);
                              }
                            }finally{
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }else{
                            setState(() {
                              customerInvoices = searchEngine(
                                  value: value,
                                  key: 'invoice_id',
                                  temps: customerInvoices);
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
