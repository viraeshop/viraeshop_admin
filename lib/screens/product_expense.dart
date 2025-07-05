import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';

class ProductExpense extends StatefulWidget {
  const ProductExpense({Key? key}) : super(key: key);

  @override
  _ProductExpenseState createState() => _ProductExpenseState();
}

class _ProductExpenseState extends State<ProductExpense> {
  GeneralCrud generalCrud = GeneralCrud();
  @override
  void initState() {
    // TODO: implement initState
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
          'Product Expense',
          style: kAppBarTitleTextStyle,
        ),
        centerTitle: true,
        titleTextStyle: kTextStyle1,
        // bottom: TabBar(
        //   tabs: tabs,
        // ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('product_expense').get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final expenses = snapshot.data!.docs;
            List<Map> expenseList = [];
            num totalExpense = 0.0;
            for (var element in expenses) {
                expenseList.add({
                  'id': element.id,
                  'cost': element.get('cost'),
                  'description': element.get('description'),
                  'title': element.get('title'),
                  'added_on': element.get('added_on'),
                });
                totalExpense += element.get('cost');
              }
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
                                Timestamp dateTime = expenseList[i]['added_on'];
                                DateTime date = dateTime.toDate();
                                return GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    color: kBackgroundColor,
                                    padding: const EdgeInsets.all(8.0),
                                    margin: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      leading: ClipRRect(
                                          child: Image.asset(
                                        'assets/default.jpg',
                                        width: 60,
                                        fit: BoxFit.cover,
                                      )),
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
                                                  'BDT ${expenseList[i]['cost'].toString()}',
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
                                                  date.toString(),
                                                  style: const TextStyle(
                                                      color: kMainColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            expenseList[i]['description'].toString(),
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
                                  'BDT ${totalExpense.toString()}',
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
                    )
                  : const Text('Loading'),
            );
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
}
