import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';

class ReturnInfo extends StatefulWidget {
  Map returnedProd = {};
  ReturnInfo({Key? key, required this.returnedProd}) : super(key: key);

  @override
  _ReturnInfoState createState() => _ReturnInfoState();
}

class _ReturnInfoState extends State<ReturnInfo> {
  var default_status = '';
  var selected_status = '';
  var selected_refund = '';
  final _statuses = ['Approved', 'Declined', 'Pending'];
  final _refundStatuses = ['Refunded', 'Not-refunded'];
  bool loadMe = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(jsonEncode(widget.returnedProd));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kSelectedTileColor),
        elevation: 0.0,
        backgroundColor: kBackgroundColor,
        title: const Text(
          'Return Info',
          style: kAppBarTitleTextStyle,
        ),
        centerTitle: true,
        titleTextStyle: kTextStyle1,
      ),
      body: LayoutBuilder(
        builder: (context, constraint) => SizedBox(
          width: constraint.maxWidth > 600
              ? MediaQuery.of(context).size.width * 0.40
              : null,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Stack(
                children: [
                  Visibility(
                      visible: true,
                      child: Center(
                        child: ListView(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          shrinkWrap: true,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Center(
                                child: Text(
                                    '${widget.returnedProd['quantity']} ${widget.returnedProd['name']} returned by ${widget.returnedProd['returned_by'].toString().toUpperCase()}')),
                            const SizedBox(
                              height: 20,
                            ),
                            DropdownButtonFormField(
                              decoration: const InputDecoration(
                                  // border: OutlineInputBorder(
                                  //     borderRadius: BorderRadius.circular(15)),
                                  // labelText: "Quantity",
                                  // hintText: "Quantity",
                                  hintStyle: TextStyle(color: Colors.black87)),
                              hint: const Text(
                                  'Select Status'), // Not necessary for Option 1
                              // value: default_status,
                              onChanged: (changeVal) {
                                print(changeVal);
                                setState(() {
                                  selected_status =
                                      changeVal.toString().toLowerCase();
                                  // print(selected_status);
                                });
                              },
                              items: _statuses.map((itm) {
                                return DropdownMenuItem(
                                  value: itm,
                                  child: Text(itm),
                                );
                              }).toList(),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            DropdownButtonFormField(
                              decoration: const InputDecoration(
                                  // border: OutlineInputBorder(
                                  //     borderRadius: BorderRadius.circular(15)
                                  //     ),
                                  // labelText: "Quantity",
                                  // hintText: "Quantity",
                                  hintStyle: TextStyle(color: Colors.black87)),
                              hint: const Text(
                                  'Select Return Status'), // Not necessary for Option 1
                              // value: default_status,
                              onChanged: (changeVal) {
                                print(changeVal);
                                setState(() {
                                  selected_refund =
                                      changeVal.toString().toLowerCase();
                                  // print(selected_refund);
                                });
                              },
                              items: _refundStatuses.map((itm) {
                                return DropdownMenuItem(
                                  value: itm,
                                  child: Text(itm),
                                );
                              }).toList(),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            bottomCard(
                              context: context,
                              text: 'Update',
                              onTap: () async {
                                if (selected_refund != '' &&
                                    selected_status != '') {
                                  setState(() {
                                    loadMe = true;
                                  });
                                  // Not Updated
                                  AdminCrud().updateReturn(
                                      '${widget.returnedProd['return_id']}', {
                                    'status': selected_status,
                                    'refund_status': selected_refund
                                  }).then((retVal) {
                                    setState(() {
                                      loadMe = false;
                                    });
                                    // Send result
                                    print('Product return updated');
                                  });
                                } else {
                                  // Cannot be empty
                                  print('Empty');
                                }
                              },
                            )
                          ],
                        ),
                      )),
                  Center(
                    child: myLoader(text: 'Loading..', visibility: loadMe),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
