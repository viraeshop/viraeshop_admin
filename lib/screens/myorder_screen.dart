import 'dart:math';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final DataTableSource _data = MyData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // drawer: AppDrawer(),
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: kBackgroundColor,
          leading: Builder(
            builder: (BuildContext context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(
                Icons.menu,
                color: kTextColor1,
              ),
            ),
          ),
          title: const Text(
            'Orders',
            style: kAppBarTitleTextStyle,
          ),
          actions: const [
            // IconButton(
            //     color: kMainColor,
            //     onPressed: () {
            //       Navigator.push(context,
            //           MaterialPageRoute(builder: (context) => NewUser()));
            //     },
            //     icon: Icon(FontAwesomeIcons.userPlus)),
          ],
        ),
        body: Container(
          // child: ListView.builder(
          //   itemCount: 10,
          //   itemBuilder: (BuildContext context, int i) {
          //     return OrderWidget(
          //         name: 'Product Name ${i + 1}', count: i, price: i);
          //   },
          // ),
          child: PaginatedDataTable(
            source: _data,
            header: const Text('My Products'),
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Order ID')),
              DataColumn(label: Text('Customer')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Status'))
            ],
            columnSpacing: 20,
            // horizontalMargin: 10,
            rowsPerPage: 8,
            showCheckboxColumn: false,
          ),
        ));
  }
}

class MyData extends DataTableSource {
  // Generate some made-up data
  final List<Map<String, dynamic>> _data = List.generate(
      200,
      (index) => {
            "id": index,
            "title": "Item $index",
            "price": Random().nextInt(10000)
          });

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _data.length;
  @override
  int get selectedRowCount => 0;
  @override
  DataRow getRow(int index) {
    return DataRow(cells: [
      DataCell(Text('$index-01-21')),
      DataCell(Text(_data[index]['id'].toString())),
      DataCell(Text(_data[index]["title"])),
      DataCell(Text('\$${_data[index]["price"]}')),
      const DataCell(Text(/*_data[index]["price"].toString()*/ 'Paid')),
    ]);
  }
}
