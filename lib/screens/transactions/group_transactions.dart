import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_bloc/transactions/barrel.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/transactions/transaction_details.dart';
import 'package:viraeshop_api/utils/utils.dart';
import 'user_transaction_screen.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupTransactions extends StatefulWidget {
  const GroupTransactions({Key? key}) : super(key: key);


  @override
  _GroupTransactionsState createState() => _GroupTransactionsState();
}

class _GroupTransactionsState extends State<GroupTransactions> {
  List transactionData = [];
  Tuple2 totalBalance = const Tuple2<num, num>(0, 0);
  Tuple2 totalBalanceTemp = const Tuple2<num, num>(0, 0);
  DateTime begin = DateTime.now();
  DateTime end = DateTime.now();
  @override
  void initState() {
    final transactionBloc = BlocProvider.of<TransactionsBloc>(context);
    transactionBloc.add(
      GetTransactionDetailsEvent(
        queryType: 'customers',
        isFilter: false,
        token: jWTToken,
      ),
    );

    // TODO: implement initState
    // List generalItems = [], agentsItems = [], architectItems = [];
    // for (var element in widget.data) {
    //   if (element['role'] == 'general') {
    //     generalItems.add(element);
    //   } else if (element['role'] == 'agents') {
    //     agentsItems.add(element);
    //   } else {
    //     architectItems.add(element);
    //   }
    //   setState(() {
    //     transactionData['General'] = generalItems;
    //     transactionData['Agents'] = agentsItems;
    //     transactionData['Architects'] = architectItems;
    //   });
    // }
    // setState(() {
    //   balances = <String, Tuple2>{
    //     'General': tuple(transactionData['General']!),
    //     'Agents': tuple(transactionData['Agents']!),
    //     'Architects': tuple(transactionData['Architects']!),
    //   };
    //   balancesTemp = balances;
    //   totalBalance = tuple(widget.data);
    //   totalBalanceTemp = totalBalance;
    // });
    super.initState();
  }
  final jWTToken = Hive.box('adminInfo').get('token');
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionsBloc, TransactionState>(
      listener: (context, state){
        if (state is OnErrorTransactionState) {
          setState(() {
            isLoading = false;
          });
        } else if (state is RequestFinishedTransactionState) {
          final data = state.response.result;
          print(data);
          setState(() {
            isLoading = false;
            if(data!.isNotEmpty){
              totalBalance =
                  Tuple2(data['totalSales'] ?? 0, data['totalDue'] ?? 0);
              totalBalanceTemp = totalBalance;
              transactionData = data['details'].where((element){
                String role = element['role'] ?? '';
                return role.isNotEmpty;
              }).toList();
            }
          });
        }
      },
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: const SizedBox(
          height: 100.0,
          width: 100.0,
          child: LoadingIndicator(
            indicatorType: Indicator.lineScale,
            colors: [kMainColor, kBlueColor, kRedColor, kYellowColor],
            strokeWidth: 2,
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                final transactionBloc = BlocProvider.of<TransactionsBloc>(context);
                transactionBloc.add(
                  GetTransactionDetailsEvent(
                    queryType: 'all',
                    isFilter: false,
                    token: jWTToken,
                  ),
                );
                Navigator.pop(context);
              },
              icon: const Icon(FontAwesomeIcons.chevronLeft),
              color: kSubMainColor,
              iconSize: 20.0,
            ),
            title: const Text(
              'Customers',
              style: kAppBarTitleTextStyle,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  final transactionBloc =
                  BlocProvider.of<TransactionsBloc>(context);
                  transactionBloc.add(
                    GetTransactionDetailsEvent(
                      queryType: 'customers',
                      isFilter: false,
                      token: jWTToken,
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                color: kSubMainColor,
                iconSize: 30.0,
              ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              FractionallySizedBox(
                heightFactor: 0.7,
                alignment: Alignment.topCenter,
                child: ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: transactionData.length,
                    itemBuilder: (context, i) {
                      return InfoWidget(
                          textWidget: rowWidget(
                              transactionData[i]['totalSales'].toString(),
                              transactionData[i]['totalDue'].toString()),
                          title: transactionData[i]['role'].toUpperCase(),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return UserTransactionScreen(
                                  userID: transactionData[i]['role'],
                                  queryType: 'roleInvoices',
                                  isFromEmployee: false,
                                  name: transactionData[i]['role'].toUpperCase(),
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
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
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
                            title: begin.toString().split(' ')[0],
                            onTap: () {
                              buildMaterialDatePicker(context, true);
                            },
                          ),
                          const Icon(
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
                          const SizedBox(
                            width: 20.0,
                          ),
                          roundedTextButton(onTap: () {
                            setState(() {
                              isLoading = true;
                            });
                            final beginFormat = DateTime(begin.year, begin.month, begin.day);
                            final endFormat = DateTime(end.year, end.month, end.day);
                            if(beginFormat == endFormat){
                              int day = begin.day;
                              int month = begin.month;
                              int year = begin.year;
                              if(lastDayOfMonth(begin.day, begin.month) == LastDay.lastDay){
                                end = DateTime(begin.year, month++, 1);
                              }else if(lastDayOfMonth(begin.day, begin.month) == LastDay.endingYear){
                                end = DateTime(year++, 1, 1);
                              }else{
                                begin = DateTime(begin.year, begin.month, day++);
                              }
                            }
                            final transactionBloc =
                            BlocProvider.of<TransactionsBloc>(
                                context);
                            transactionBloc.add(
                              GetTransactionDetailsEvent(
                                queryType: 'customers',
                                isFilter: true,
                                token: jWTToken,
                                begin: dateToJson(
                                  Timestamp.fromDate(begin),
                                ),
                                end: dateToJson(
                                  Timestamp.fromDate(end),
                                ),
                              ),
                            );
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
                          const SizedBox(
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
  for (var element in items) {
    sale += element['price'];
    due += element['due'];
  }
  Tuple2 data = Tuple2<num, num>(sale, due);
  return data;
}

Tuple2 dateTuple(List items, DateTime begin, DateTime end) {
  num sale = 0, due = 0;
  for (var element in items) {
    Timestamp timestamp = element['date'];
    DateTime date = timestamp.toDate();
    begin = DateTime(begin.year, begin.month, begin.day);
    end = DateTime(end.year, end.month, end.day);
    DateTime dateFormatted = DateTime(date.year, date.month, date.day);
    if ((begin.isAfter(dateFormatted) ||
            begin.isAtSameMomentAs(dateFormatted)) &&
        (end.isBefore(dateFormatted) || end.isAtSameMomentAs(dateFormatted))) {
      sale += element['price'];
      due += element['due'];
    }
  }
  Tuple2 data = Tuple2<num, num>(sale, due);
  return data;
}
