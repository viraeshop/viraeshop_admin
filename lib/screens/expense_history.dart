import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:viraeshop_bloc/expense/expense_event.dart';
import 'package:viraeshop_bloc/expense/expense_state.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/boxes.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_bloc/expense/expense_bloc.dart';
import 'package:viraeshop_api/models/expense/expense.dart';
import 'package:viraeshop_api/utils/utils.dart';

class ExpenseHistory extends StatefulWidget {
  const ExpenseHistory({Key? key}) : super(key: key);

  @override
  _ExpenseHistoryState createState() => _ExpenseHistoryState();
}

class _ExpenseHistoryState extends State<ExpenseHistory> {
  GeneralCrud generalCrud = GeneralCrud();
  @override
  void initState() {
    // TODO: implement initState
    final expenseBloc = BlocProvider.of<ExpenseBloc>(context);
    final jWTToken = Hive.box('adminInfo').get('token');
    expenseBloc.add(GetExpensesEvent(
      token: jWTToken
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kSelectedTileColor),
        elevation: 0.0,
        backgroundColor: kBackgroundColor,
        title: const Text(
          'Expense History',
          style: kAppBarTitleTextStyle,
        ),
        centerTitle: true,
        titleTextStyle: kTextStyle1,
        // bottom: TabBar(
        //   tabs: tabs,
        // ),
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is FetchedExpensesState) {
            List<ExpenseModel> expenses = state.expenses;
            List<Map> expenseList = [];
            num totalExpense = 0.0;
            for (var element in expenses) {
              expenseList.add({
                'id': element.id,
                'cost': element.cost,
                'description': element.description,
                'title': element.title,
                'image': element.image,
                'createdAt': element.createdAt,
                'addedBy': element.addedBy['name'],
              });
              totalExpense += element.cost;
            }
            return Container(
              color: kScaffoldBackgroundColor,
              child: Stack(
                      fit: StackFit.expand,
                      children: [
                        FractionallySizedBox(
                            heightFactor: 0.88,
                            alignment: Alignment.topCenter,
                            child: ListView.builder(
                              itemCount: expenses.length,
                              itemBuilder: (BuildContext context, int i) {
                                Timestamp dateTime =
                                    dateFromJson(expenseList[i]['createdAt']);
                                DateTime dateFormat = dateTime.toDate();
                                String date =
                                    DateFormat.yMMMd().format(dateFormat);
                                return GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    color: kBackgroundColor,
                                    padding: const EdgeInsets.all(8.0),
                                    margin: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      leading: ClipRRect(
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          width: 60.0,
                                          imageUrl: expenseList[i]['image'],
                                          errorWidget: (context, url, childs) {
                                            return Image.asset(
                                              'assets/default.jpg',
                                              width: 60,
                                            );
                                          },
                                        ),
                                      ),
                                      title: Text(
                                        '${expenseList[i]['title']}',
                                        style: kProductNameStylePro,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${expenseList[i]['cost']}$bdtSign',
                                                  style: const TextStyle(
                                                    color: kMainColor,
                                                    fontSize: 15.0,
                                                    letterSpacing: 1.3,
                                                    fontFamily: 'Montserrat',
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  date,
                                                  style: const TextStyle(
                                                      color: kMainColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${expenseList[i]['description']}',
                                            style: kProductNameStylePro,
                                          ),
                                          const SizedBox(height: 20)
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )),
                        FractionallySizedBox(
                          heightFactor: 0.12,
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            color: kSubMainColor,
                            width: double.infinity,
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Expenses',
                                  style: TextStyle(
                                    color: kBackgroundColor,
                                    fontSize: 15.0,
                                    letterSpacing: 1.3,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                Text(
                                  '${totalExpense.toString()}$bdtSign',
                                  style: const TextStyle(
                                    color: kMainColor,
                                    fontSize: 15.0,
                                    letterSpacing: 1.3,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            );
          } else if (state is OnErrorExpenseState) {
            return Center(
                child: Text(
              state.message,
              style: kProductNameStylePro,
            ));
          }
          return const Center(
            child: CircularProgressIndicator(
              color: kMainColor,
            ),
          );
        },
      ),
    );
  }

  // Dialog
  Future<void> _showMyDialog({var title = "Error"}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Text('This is a demo alert dialog.'),
                // Text('$msg'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: myField(hint: 'Reason'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: myField(hint: 'Quantity'),
                ),

                const SizedBox(height: 20),
                InkWell(
                  child: Container(
                    width: double.infinity, //MediaQuery.of(context).size.width,
                    height: 40,
                    decoration: BoxDecoration(
                        color:
                            kSelectedTileColor, //Theme.of(context).accentColor,
                        borderRadius: BorderRadius.circular(15)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Return",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    // addProduct();
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
