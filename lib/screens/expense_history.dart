import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/product_info.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';

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
    super.initState();

    generalCrud.getExpense().then((v) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: kSelectedTileColor),
        elevation: 0.0,
        backgroundColor: kBackgroundColor,
        title: Text(
          'Expense History',
          style: kAppBarTitleTextStyle,
        ),
        centerTitle: true,
        titleTextStyle: kTextStyle1,
        // bottom: TabBar(
        //   tabs: tabs,
        // ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('expenses').get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final expenses = snapshot.data!.docs;
            List<Map> expenseList = [];
            num totalExpense = 0.0;
            expenses.forEach(
              (element) {
                expenseList.add({
                  'id': element.id,
                  'cost': element.get('cost'),
                  'description': element.get('description'),
                  'title': element.get('title'),
                  'image': element.get('image'),
                  'date': element.get('date'),
                  'added_by': element.get('added_by'),
                });
                totalExpense += element.get('cost');
              },
            );
            return Container(
              color: kScaffoldBackgroundColor,
              child: expenseList.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        FractionallySizedBox(
                            heightFactor: 0.88,
                            alignment: Alignment.topCenter,
                            child: ListView.builder(
                              itemCount: expenses.length,
                              itemBuilder: (BuildContext context, int i) {
                                Timestamp dateTime = expenseList[i]['date'];
                                DateTime dateFormat = dateTime.toDate();
                                String date = DateFormat.yMMMd().format(dateFormat);
                                return GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    color: kBackgroundColor,
                                    padding: EdgeInsets.all(8.0),
                                    margin: EdgeInsets.all(8.0),
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
                                                  'BDT ${expenseList[i]['cost']}',
                                                  style: TextStyle(
                                                    color: kMainColor,
                                                    fontSize: 15.0,
                                                    letterSpacing: 1.3,
                                                    fontFamily: 'Montserrat',
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  '$date',
                                                  style: TextStyle(
                                                      color: kMainColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${expenseList[i]['description']}',
                                            style: kProductNameStylePro,
                                          ),
                                          SizedBox(height: 20)
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
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Expenses',
                                  style: TextStyle(
                                    color: kBackgroundColor,
                                    fontSize: 15.0,
                                    letterSpacing: 1.3,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                Text(
                                  'BDT ${totalExpense.toString()}',
                                  style: TextStyle(
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
                    )
                  : Text('Loading'),
            );
          }
          return Center(
            child: CircularProgressIndicator(
              color: kMainColor,
            ),
          );
        },
      ),
    );
  }

  // Dialog
  Future<void> _showMyDialog({var title = "Error", var msg}) async {
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

                SizedBox(height: 20),
                InkWell(
                  child: Container(
                    width: double.infinity, //MediaQuery.of(context).size.width,
                    height: 40,
                    decoration: BoxDecoration(
                        color:
                            kSelectedTileColor, //Theme.of(context).accentColor,
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(
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
              child: Text('Cancel'),
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
