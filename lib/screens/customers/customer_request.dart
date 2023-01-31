import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop/customers/barrel.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/functions.dart';
import 'package:viraeshop_admin/reusable_widgets/buttons/dialog_button.dart';
import 'package:viraeshop_admin/screens/customers/new_customer_info.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop/customers/customers_bloc.dart';

class CustomerRequests extends StatefulWidget {
  const CustomerRequests({Key? key}) : super(key: key);

  @override
  _CustomerRequestsState createState() => _CustomerRequestsState();
}

class _CustomerRequestsState extends State<CustomerRequests> {
  AdminCrud adminCrud = AdminCrud();
  @override
  void initState() {
    // TODO: implement initState
    final customerBloc = BlocProvider.of<CustomersBloc>(context);
    final jWTToken = Hive.box('adminInfo').get('token');
    customerBloc.add(GetCustomersEvent(
        token: jWTToken,
        query: 'all', isNewRequest: 'true'));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kSpecialBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            FontAwesomeIcons.chevronLeft,
            color: kSubMainColor,
            size: 20.0,
          ),
        ),
        title: const Text(
          'Customers Requests',
          style: kProductNameStylePro,
        ),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        margin: const EdgeInsets.all(7.0),
        child: BlocBuilder<CustomersBloc, CustomerState>(
            builder: (context, state) {
              if (state is FetchedCustomersState) {
                final data = state.customerList;
                int index = 0;
                List requests = [];
                for (var element in data) {
                  requests.add(element.toJson());
                }
                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        elevation: 5.0,
                        color: kBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.person,
                                  color: kNewTextColor,
                                  size: 45.0,
                                ),
                                title: Text(
                                  '${requests[i]['name']}',
                                  style: kProductNameStylePro,
                                ),
                              ),
                              // SizedBox(
                              //   height: 10.0,
                              // ),
                              ListTile(
                                leading: const Icon(
                                  Icons.call,
                                  size: 20.0,
                                  color: kSubMainColor,
                                ),
                                title: Text(
                                  '${requests[i]['mobile']}',
                                  style: kProductNameStylePro,
                                ),
                              ),
                              // SizedBox(
                              //   height: 10.0,
                              // ),
                              ListTile(
                                leading: const Icon(
                                  Icons.mail,
                                  size: 20.0,
                                  color: kSubMainColor,
                                ),
                                title: Text(
                                  '${requests[i]['email']}',
                                  style: kProductNameStylePro,
                                ),
                              ),
                              // SizedBox(
                              //   height: 10.0,
                              // ),
                              ListTile(
                                leading: const Icon(
                                  Icons.supervisor_account_outlined,
                                  size: 20.0,
                                  color: kSubMainColor,
                                ),
                                title: Text(
                                  '${requests[i]['role']}',
                                  style: kProductNameStylePro,
                                ),
                              ),
                              // SizedBox(
                              //   height: 10.0,
                              // ),
                              ListTile(
                                leading: const Icon(
                                  Icons.place,
                                  size: 20.0,
                                  color: kSubMainColor,
                                ),
                                title: Text(
                                  '${requests[i]['address']}',
                                  style: kProductNameStylePro,
                                ),
                              ),
                              // SizedBox(
                              //   height: 10.0,
                              // ),
                              DialogButton(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewCustomerInfoScreen(
                                        info: requests[i],
                                      ),
                                    ),
                                  );
                                },
                                title: 'Review',
                                width: double.infinity,
                                color: kNewTextColor,
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else if (state is OnErrorCustomerState) {
                return Center(
                  child: Text(
                    state.message,
                    style: kProductNameStylePro,
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    color: kMainColor,
                  ),
                );
              }
            }),
      ),
    );
  }
}
