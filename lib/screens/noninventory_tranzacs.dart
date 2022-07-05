import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/reusable_widgets/transaction_details.dart';
import 'non_inventory_transactions.dart';
import 'user_transaction_screen.dart';
import 'package:tuple/tuple.dart';

class NonInventoryTransactionShops extends StatefulWidget {
  final List data;
  NonInventoryTransactionShops({required this.data});

  @override
  _NonInventoryTransactionShopsState createState() =>
      _NonInventoryTransactionShopsState();
}

class _NonInventoryTransactionShopsState
    extends State<NonInventoryTransactionShops> {
  Map<String, List> transactionData = {};
  Map<String, Tuple2> balances = {};
  Map<String, Tuple2> balancesTemp = {};
  Tuple2 totalBalance = Tuple2<num, num>(0, 0);
  Tuple2 totalBalanceTemp = Tuple2<num, num>(0, 0);
  DateTime begin = DateTime.now();
  DateTime end = DateTime.now();
  Set employees = Set();
  @override
  void initState() {
    // TODO: implement initState
    List shops = [];
    widget.data.forEach((element) {
      if (element['isWithNonInventory'] == true) {
        element['shop'].forEach((nameShop) {
          shops.add(nameShop['name']);
        });
      }
    });
    Set shopSet = Set.from(shops);
    shopSet.forEach((shop) {
      List items = [];
      widget.data.forEach((element) {
        element['shop'].forEach((shopItem) {
          if (shopItem['name'] == shop) {
            items.add(element);
          }
        });
      });
      setState(() {
        transactionData[shop] = items;
      });
    });
    setState(() {
      balances = Map.fromIterable(
        shopSet,
        key: (element) => element,
        value: (element) {
          return tuple(transactionData[element]!);
        },
      );
      balancesTemp = balances;
      totalBalance = tuple(widget.data);
      totalBalanceTemp = totalBalance;
      employees = shopSet;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: balancesTemp.isEmpty,
      progressIndicator: SizedBox(
        height: 100.0,
        width: 100.0,
        child: LoadingIndicator(
          indicatorType: Indicator.lineScale,
          colors: const [kMainColor, kBlueColor, kRedColor, kYellowColor],
          strokeWidth: 2,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(FontAwesomeIcons.chevronLeft),
            color: kSubMainColor,
            iconSize: 20.0,
          ),
          title: Text(
            'Non Inventory',
            style: kAppBarTitleTextStyle,
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  balancesTemp = balances;
                  totalBalanceTemp = totalBalance;
                });
              },
              icon: Icon(Icons.refresh),
              color: kSubMainColor,
              iconSize: 20.0,
            ),
          ],
        ),
        body: balancesTemp.isEmpty
            ? Container()
            : Container(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FractionallySizedBox(
                      heightFactor: 0.7,
                      alignment: Alignment.topCenter,
                      child: ListView.builder(
                          padding: EdgeInsets.all(10.0),
                          itemCount: balancesTemp.keys.toList().length,
                          itemBuilder: (context, i) {
                            return InfoWidget(
                                textWidget: rowWidget(
                                    '${balancesTemp[balancesTemp.keys.toList()[i]]!.item1.toString()}',
                                    '${balancesTemp[balancesTemp.keys.toList()[i]]!.item2.toString()}'),
                                title: '${balancesTemp.keys.toList()[i]}',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return NonInventoryTransactions(
                                        data: transactionData[
                                            transactionData.keys.toList()[i]]!,
                                        name: transactionData.keys.toList()[i],
                                      );
                                    }),
                                  );
                                });
                          }),
                    ),
                    FractionallySizedBox(
                      heightFactor: 0.25,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 0),
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                dateWidget(
                                  title: '${begin.toString().split(' ')[0]}',
                                  onTap: () {
                                    buildMaterialDatePicker(context, true);
                                  },
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: kSubMainColor,
                                  size: 20.0,
                                ),
                                dateWidget(
                                    onTap: () {
                                      buildMaterialDatePicker(context, false);
                                    },
                                    title: end.isAtSameMomentAs(DateTime.now())
                                        ? 'To this date..'
                                        : end.toString().split(' ')[0]),
                                SizedBox(
                                  width: 20.0,
                                ),
                                roundedTextButton(onTap: () {
                                  setState(() {
                                    balancesTemp = Map.fromIterable(
                                      employees,
                                      key: (element) => element,
                                      value: (element) {
                                        return dateTuple(
                                            transactionData[element]!,
                                            begin,
                                            end);
                                      },
                                    );
                                    totalBalanceTemp =
                                        dateTuple(widget.data, begin, end);
                                  });
                                }),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SpecialContainer(
                                  height: 110.0,
                                  width: 150.0,
                                  value: totalBalanceTemp.item1.toString(),
                                  title: 'Total Sales',
                                  color: kYellowColor,
                                ),
                                SizedBox(
                                  width: 20.0,
                                ),
                                SpecialContainer(
                                  height: 110.0,
                                  width: 150.0,
                                  value: totalBalanceTemp.item2.toString(),
                                  title: 'Total Due',
                                  color: kRedColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  buildMaterialDatePicker(BuildContext context, bool isBegin) async {
    DateTime date = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDatePickerMode: DatePickerMode.day,
      fieldHintText: 'Month/Date/Year',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(),
          child: child!,
        );
      },
    );
    if (picked != null && picked != begin) {
      if (isBegin) {
        setState(() {
          begin = picked;
        });
      } else {
        setState(() {
          end = picked;
        });
      }
    }
  }
}

Tuple2 tuple(List items) {
  num sale = 0, due = 0;
  items.forEach((element) {
    element['shop'].forEach((shop) {
      sale += shop['price'];
      due += shop['due'];
    });
  });
  Tuple2 data = Tuple2<num, num>(sale, due);
  return data;
}

Tuple2 dateTuple(List items, DateTime begin, DateTime end) {
  num sale = 0, due = 0;
  items.forEach((element) {
    Timestamp timestamp = element['date'];
    DateTime date = timestamp.toDate();
    begin = DateTime(begin.year, begin.month, begin.day);
    end = DateTime(end.year, end.month, end.day);
    DateTime dateFormatted = DateTime(date.year, date.month, date.day);
    if ((begin.isAfter(dateFormatted) ||
            begin.isAtSameMomentAs(dateFormatted)) &&
        (end.isBefore(dateFormatted) || end.isAtSameMomentAs(dateFormatted))) {
      element['shop'].forEach((shop) {
        sale += shop['price'];
        due += shop['due'];
      });
    }
  });
  Tuple2 data = Tuple2<num, num>(sale, due);
  return data;
}
