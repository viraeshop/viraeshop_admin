import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_bloc/transactions/barrel.dart';
import 'package:viraeshop_bloc/transactions/transactions_bloc.dart';
import 'package:viraeshop_bloc/transactions/transactions_event.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/reusable_widgets/transaction_functions/functions.dart';
import 'package:viraeshop_admin/screens/transactions/transaction_details.dart';
import 'package:viraeshop_api/utils/utils.dart';
import 'user_transaction_screen.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Employees extends StatefulWidget {
  const Employees({Key? key})
      : super(key: key);

  @override
  _EmployeesState createState() => _EmployeesState();
}

class _EmployeesState extends State<Employees> {
  List transactionData = [];
  Tuple2 totalBalance = const Tuple2<num, num>(0, 0);
  Tuple2 totalBalanceTemp = const Tuple2<num, num>(0, 0);
  DateTime begin = DateTime.now();
  DateTime end = DateTime.now();
  Set employees = {};
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  void initState() {
    // TODO: implement initState
    final transactionBloc = BlocProvider.of<TransactionsBloc>(context);
    transactionBloc.add(
      GetTransactionDetailsEvent(
        queryType: 'employees',
        isFilter: false,
        token: jWTToken,
      ),
    );
    // List employeeId = [];
    // for (var element in widget.data) {
    //   employeeId.add(element['adminId']);
    // }
    // Set employeeSet = Set.from(employeeId);
    // for (var employee in employeeSet) {
    //   List items = [];
    //   for (var element in widget.data) {
    //     if (element['adminId'] == employee) {
    //       items.add(element);
    //     }
    //     setState(() {
    //       transactionData[employee] = items;
    //     });
    //   }
    // }
    // setState(() {
    //   balances = { for (var element in employeeSet) element : tuple(transactionData[element]!) };
    //   balancesTemp = balances;
    //   employees = employeeSet;
    // });
    super.initState();
  }

  bool isLoading = true;
  String message = '';
  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionsBloc, TransactionState>(
      listener: (context, state) {
        if (kDebugMode) {
          print(state);
        }
        if (state is OnErrorTransactionState) {
          setState(() {
            isLoading = false;
            message = state.message;
          });
        } else if (state is RequestFinishedTransactionState) {
          final Map<String, dynamic> data = state.response.result ?? {};
          final invoices = data['details'] ?? [];
          setState(() {
            isLoading = false;
            totalBalance =
                Tuple2(data['totalSales'] ?? 0, data['totalDue'] ?? 0);
            totalBalanceTemp = totalBalance;
            transactionData = invoices.toList();
            if(transactionData.isEmpty){
              message = 'No available history';
            }
          });
        } else if (state is LoadingTransactionState){
          setState(() {
            isLoading = true;
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
              iconSize: 30.0,
            ),
            title: const Text(
              'Employees',
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
                      queryType: 'employees',
                      isFilter: false,
                      token: jWTToken,
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                color: kSubMainColor,
                iconSize: 20.0,
              ),
            ],
          ),
          body: transactionData.isEmpty
              ? Center(
                child: Text(message, style: kProductNameStylePro,),
              )
              : Stack(
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
                                title: transactionData[i]['adminInfo.name'],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return UserTransactionScreen(
                                        name: transactionData[i]['adminInfo.name'],
                                        userID: transactionData[i]['adminId'],
                                        queryType: 'adminInvoices',
                                      );
                                    }),
                                  );
                                });
                          }),
                    ),
                    SafeArea(
                      child: FractionallySizedBox(
                        heightFactor: 0.3,
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
                                  roundedTextButton(
                                    onTap: () {
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
                                          queryType: 'employees',
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
                                    },
                                  ),
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
      lastDate: DateTime(2100),
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
