import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:viraeshop/customers/barrel.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/boxes.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/customers/register_customer.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_api/models/customers/customers.dart';

import '../update_user.dart';

class Customers extends StatefulWidget {
  final String role;
  final bool isSelectCustomer;
  const Customers({Key? key, required this.role, this.isSelectCustomer = false})
      : super(key: key);
  @override
  _CustomersState createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  GeneralCrud generalCrud = GeneralCrud();
  num agentsBalances = 0;
  num agentsBalancesBackup = 0;
  List<CustomerModel> customersList = [];
  List<CustomerModel> tempStore = [];
  TextEditingController controller = TextEditingController();
  initSearch(String value) {
    if (value.isEmpty) {
      setState(
        () {
          customersList = tempStore;
          agentsBalances = agentsBalancesBackup;
        },
      );
    }
    List<CustomerModel> items = [];
    num balances = 0;
    items = customersList.where((element) {
      final nameLower = element.name.toLowerCase();
      final mobile = element.mobile;
      final businessName =
          element.role != 'general' && element.businessName != null
              ? element.businessName?.toLowerCase()
              : '';
      if (element.role == 'agents') {
        balances += element.wallet ?? 0;
      }
      final email = element.email;
      final valueLower = value.toLowerCase();
      return nameLower.contains(valueLower) ||
          mobile.contains(valueLower) ||
          businessName!.contains(valueLower) ||
          email.contains(valueLower);
    }).toList();
    if (customersList.isEmpty && value.isNotEmpty) {
      items = tempStore.where((element) {
        final nameLower = element.name.toLowerCase();
        final mobile = element.mobile;
        final businessName =
            element.role != 'general' && element.businessName != null
                ? element.businessName?.toLowerCase()
                : '';
        final valueLower = value.toLowerCase();
        return nameLower.contains(valueLower) ||
            mobile.contains(valueLower) ||
            businessName!.contains(valueLower);
      }).toList();
    }
    final List<CustomerModel> filtered = items;
    setState(() {
      customersList = filtered;
      agentsBalances = balances;
      // if(customersList.isEmpty && value.length != 0){
      //   customersList = tempStore;
      // }
    });
  }

  String statusMessage = 'Fetching customers please wait...';
  bool isNumeric(String value) {
    return RegExp(r'^[0-9]+$').hasMatch(value);
  }

  @override
  void initState() {
    // TODO: implement initState
    final customerBloc = BlocProvider.of<CustomersBloc>(context);
    final jWTToken = Hive.box('adminInfo').get('token');
    customerBloc.add(GetCustomersEvent(token: jWTToken, query: widget.role));
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print('Im getting disposed ${widget.role}');
    // final customerBloc = BlocProvider.of<CustomersBloc>(context);
    // customerBloc.close();
    super.dispose();
  }

  bool loaded = false;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomersBloc, CustomerState>(
      builder: (context, state) {
        if (state is FetchedCustomersState) {
          if (!loaded) {
            customersList = state.customerList.toList();
            tempStore = customersList.toList();
            for (var customer in customersList) {
              if (widget.role == 'agents') {
                agentsBalances += customer.wallet ?? 0;
                agentsBalancesBackup += customer.wallet ?? 0;
              }
            }
            loaded = true;
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 70.0),
                child: FractionallySizedBox(
                  alignment: Alignment.topCenter,
                  heightFactor: widget.role == 'agents' ? 0.88 : 1,
                  child: ListView.builder(
                    itemCount: customersList.length,
                    itemBuilder: (context, i) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: ListTile(
                            onTap: () {
                              if (widget.isSelectCustomer) {
                                onSelectCustomer(
                                    context, customersList[i].toJson());
                              } else {
                                onCustomerTap(
                                  context,
                                  customersList[i].toJson(),
                                  widget.role,
                                );
                              }
                            },
                            leading: CircleAvatar(
                              radius: 60.0,
                              backgroundColor: kNewTextColor,
                              backgroundImage: NetworkImage(
                                  customersList[i].profileImage ?? ''),
                              child: Text('$i'),
                            ),
                            trailing: const Icon(Icons.arrow_right),
                            title: Text(customersList[i].name,
                                style: const TextStyle(color: kMainColor)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (customersList[i].role != 'general')
                                  Text(
                                    '${customersList[i].businessName}',
                                    style: kProductNameStylePro,
                                  ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  customersList[i].mobile,
                                  style: kTableCellStyle,
                                ),
                                if (customersList[i].email.isNotEmpty)
                                  Text(
                                    customersList[i].email,
                                    style: kProductNameStylePro,
                                  ),
                                if (widget.role == 'agents')
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${customersList[i].wallet}$bdtSign',
                                        style: const TextStyle(
                                          color: kNewMainColor,
                                          fontFamily: 'Montserrat',
                                          fontSize: 15,
                                          letterSpacing: 1.3,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 70.0,
                  width: double.infinity,
                  color: kspareColor,
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: TextFormField(
                      textAlignVertical: TextAlignVertical.bottom,
                      controller: controller,
                      decoration: InputDecoration(
                        suffixIcon: (isNumeric(controller.text) &&
                                    controller.text.length == 11) &&
                                customersList.isEmpty
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RegisterCustomer(
                                            mobile: controller.text,
                                          ),
                                    ),
                                  );
                                },
                                child: const Chip(
                                  label: Text('Create Account'),
                                  labelStyle: kProductNameStylePro,
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        hintText: 'Search by name or phone number',
                        hintStyle: const TextStyle(
                          color: kSubMainColor,
                          fontSize: 15.0,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 30.0,
                          color: kSubMainColor,
                        ),
                      ),
                      onChanged: (value) {
                        // print(value.length);
                        initSearch(value);
                      },
                    ),
                  ),
                ),
              ),
              if (widget.role == 'agents')
                FractionallySizedBox(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 0.12,
                  child: Container(
                    width: double.infinity,
                    color: kSubMainColor,
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Total Balance:',
                          style: TextStyle(
                            color: kBackgroundColor,
                            fontSize: 20.0,
                            letterSpacing: 1.3,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' ${agentsBalances.toString()}$bdtSign',
                          style: const TextStyle(
                            color: kMainColor,
                            fontSize: 15.0,
                            letterSpacing: 1.3,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            ],
          );
        } else if (state is OnErrorCustomerState) {
          loaded = false;
          return Center(
            child: Text(
              state.message,
              style: kProductNameStylePro,
            ),
          );
        }
        loaded = false;
        return const Center(
          child: Text(
            'please wait fetching customers....',
            style: kProductNameStylePro,
          ),
        );
      },
    );
  }
}

void onCustomerTap(BuildContext context, Map customersList, String role) {
  Map<String, dynamic> userInfo = {
    'name': customersList['name'],
    'mobile': customersList['mobile'],
    'address': customersList['address'],
    'customerId': customersList['customerId'],
    'email': customersList['email'],
    'role': customersList['role'],
    'idType': customersList['idType'],
    'idImage': customersList['idImage'],
    'idNumber': customersList['idNumber'],
  };
  if (customersList['role'] != 'general') {
    userInfo['businessName'] = customersList['businessName'];
  }
  if (customersList['role'] == 'agents') {
    userInfo['wallet'] = customersList['wallet'];
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UpdateUser(
          userInfo: userInfo, userId: userInfo['customerId'], role: role),
    ),
  );
}

void onSelectCustomer(BuildContext context, Map customersList) {
  Map info = {
    'id': customersList['customerId'],
    'role': customersList['role'],
    'name': customersList['name'],
    'address': customersList['address'],
    'mobile': customersList['mobile'],
    'email': customersList['email'],
    'search_keywords': customersList['search_keywords'],
    'businessName': customersList['businessName'],
  };
  if (customersList['role'] == 'agents') {
    info['wallet'] = customersList['wallet'];
  }
  Hive.box('customer').putAll(info);
  Navigator.pop(context);
  snackBar(
    text: 'Customer info added',
    context: context,
    duration: 30,
    color: kNewMainColor,
  );
}
