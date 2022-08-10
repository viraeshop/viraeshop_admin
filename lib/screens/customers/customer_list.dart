import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/baxes.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/user_profile_info.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';

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
  num storeCredit = 0;
  List customersList = [];
  List tempStore = [];
  initSearch(String value) {
    if (value.isEmpty) {
      setState(
        () {
          customersList = tempStore;
        },
      );
    }
    List items = [];
    items = customersList.where((element) {
      final nameLower = element['name'].toLowerCase();
      final mobile = element['mobile'];
      final businessName =
      widget.role != 'general' && element['business_name'] != null
          ? element['business_name'].toLowerCase()
          : '';
      print(businessName);
      final valueLower = value.toLowerCase();
      return nameLower.contains(valueLower) ||
          mobile.contains(valueLower) ||
          businessName.contains(valueLower);
    }).toList();
    if (customersList.isEmpty && value.isNotEmpty) {
      items = tempStore.where((element) {
        final nameLower = element['name'].toLowerCase();
        final mobile = element['mobile'];
        final businessName =
            widget.role != 'general' && element['business_name'] != null
                ? element['business_name'].toLowerCase()
                : '';
        print(businessName);
        final valueLower = value.toLowerCase();
        return nameLower.contains(valueLower) ||
            mobile.contains(valueLower) ||
            businessName.contains(valueLower);
      }).toList();
    }
    final List filtered = items;
    setState(() {
      customersList = filtered;
      // if(customersList.isEmpty && value.length != 0){
      //   customersList = tempStore;
      // }
    });
  }

  bool isLoaded = false;
  String statusMessage = 'Fetching customers please wait...';
  @override
  void initState() {
    generalCrud.getCustomerList(widget.role).then((snapshot) {
      final data = snapshot.docs;
      for (var element in data) {
        setState(() {
          customersList.add(element.data());
          if(widget.role == 'agents'){
            storeCredit += element.get('wallet');
          }
        });
      }
      setState(() {
        isLoaded = true;
        tempStore = customersList;
      });
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      setState(() {
        statusMessage = 'Failed to fetch customers';
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoaded
        ? Stack(
      fit: StackFit.expand,
          children: [
            FractionallySizedBox(
              alignment: Alignment.topCenter,
              heightFactor: widget.role == 'agents' && !widget.isSelectCustomer ?  0.88 : 1,
              child: ListView.builder(
                  itemCount: customersList.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Container(
                        height: 70.0,
                        width: double.infinity,
                        color: kspareColor,
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                          child: TextFormField(
                            textAlignVertical: TextAlignVertical.bottom,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              hintText: 'Search by name or phone number',
                              hintStyle: TextStyle(
                                color: kSubMainColor,
                                fontSize: 15.0,
                              ),
                              prefixIcon: Icon(
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
                      );
                    }
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: ListTile(
                          onTap: () {
                            if (widget.isSelectCustomer) {
                              onSelectCustomer(context, customersList[i - 1]);
                            } else {
                              onCustomerTap(context, customersList[i - 1]);
                            }
                          },
                          leading: CircleAvatar(
                            radius: 60.0,
                            backgroundColor: kNewTextColor,
                            child: Text('${i + 1}'),
                          ),
                          trailing: const Icon(Icons.arrow_right),
                          title: Text('${customersList[i - 1]['name']}',
                              style: const TextStyle(color: kMainColor)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if(widget.role != 'general') Text(
                                '${customersList[i - 1]['business_name']}',
                                style: kProductNameStylePro,
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                '${customersList[i - 1]['mobile']}',
                                style: kTableCellStyle,
                              ),
                              if (customersList[i - 1]['email'] != null)
                                Text(
                                  '${customersList[i - 1]['email']}',
                                  style: kProductNameStylePro,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ),
            if(widget.role == 'agents' && !widget.isSelectCustomer) FractionallySizedBox(
              alignment: Alignment.bottomCenter,
              heightFactor: 0.12,
              child: Container(
                width: double.infinity,
                color: kSubMainColor,
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Receivables',
                          style: TextStyle(
                            color: kBackgroundColor,
                            fontSize: 15.0,
                            letterSpacing: 1.3,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        Text(
                          'BDT 0.0',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 15.0,
                            letterSpacing: 1.3,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Store Credits',
                          style: TextStyle(
                            color: kBackgroundColor,
                            fontSize: 15.0,
                            letterSpacing: 1.3,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        Text(
                          '${storeCredit.toString()}$bdtSign',
                          style: const TextStyle(
                            color: kMainColor,
                            fontSize: 15.0,
                            letterSpacing: 1.3,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        )
        : Center(
            child: Text(
              statusMessage,
              style: kProductNameStylePro,
            ),
          );
  }
}

void onCustomerTap(BuildContext context, Map customersList) {
  Map<String, dynamic> userInfo = {
    'name': customersList['name'],
    'mobile': customersList['mobile'],
    'address': customersList['address'],
    'userId': customersList['userId'],
    'email': customersList['email'],
    'role': customersList['role'],
    'idType': customersList['idType'],
    'idImage': customersList['idImage'],
    'idNumber': customersList['idNumber'],
  };
  if (customersList['role'] == 'agents') {
    userInfo['wallet'] = customersList['wallet'];
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UserProfileInfo(
        userInfo: userInfo,
        docId: userInfo['userId'],
      ),
    ),
  );
}

void onSelectCustomer(BuildContext context, Map customersList) {
  Map info = {
    'id': customersList['userId'],
    'role': customersList['role'],
    'name': customersList['name'],
    'address': customersList['address'],
    'mobile': customersList['mobile'],
    'email': customersList['email'],
    'search_keywords': customersList['search_keywords'],
    'business_name': customersList['business_name'],
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
