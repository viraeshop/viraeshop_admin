import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';


import 'customers/tabWidgets.dart';
import 'home_screen.dart';


class EditUserScreen extends StatefulWidget {
  var adminInfo;
  EditUserScreen({required this.adminInfo});
  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  bool isLoading = false;
  List<Tab> tabs = [
    Tab(text: 'Info'),
    Tab(text: 'Permissions'),
    Tab(text: 'Sales'),
  ];
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: CircularProgressIndicator(color: kMainColor),
      child: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: kBackgroundColor,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                FontAwesomeIcons.chevronLeft,
                color: kSubMainColor,
              ),
              iconSize: 15.0,
            ),
            title: Text(
              'Edit user',
              style: kProductNameStylePro,
            ),
            centerTitle: true,
            bottom: TabBar(
              tabs: tabs,
              indicatorColor: kMainColor,
              labelColor: kMainColor,
              unselectedLabelColor: kSubMainColor,
              labelStyle: TextStyle(
                color: kMainColor,
                fontSize: 15.0,
                letterSpacing: 1.3,
                fontFamily: 'Montserrat',
              ),
              unselectedLabelStyle: kProductNameStylePro,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Delete User'),
                        content: Text(
                          'Are you sure you want to remove this User?',
                          softWrap: true,
                          style: kSourceSansStyle,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              Navigator.pop(context);
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.adminInfo['adminId'])
                                  .delete()
                                  .then((value) {
                                setState(() {
                                  isLoading = false;
                                });
                                Navigator.pushNamedAndRemoveUntil(
                                    context, HomeScreen.path, (route) => false);
                              });
                            },
                            child: Text(
                              'Yes',
                              softWrap: true,
                              style: kSourceSansStyle,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'No',
                              softWrap: true,
                              style: kSourceSansStyle,
                            ),
                          )
                        ],
                      );
                    },
                  );
                },
                icon: Icon(
                  Icons.delete,
                ),
                color: kSubMainColor,
                iconSize: 20.0,
              ),
            ],
          ),
          body: TabBarView(
            children: [
              infoTab(
                id: widget.adminInfo['adminId'],
                email: widget.adminInfo['email'],
                name: widget.adminInfo['name'],
                context: context,
              ),
              PermissionTab(
                adminId: widget.adminInfo['adminId'],
                isadmin: widget.adminInfo['isAdmin'],
                isinventory: widget.adminInfo['isInventory'],
                ismakeAdmin: widget.adminInfo['isMakeAdmin'],
                ismakeCustomer: widget.adminInfo['isMakeCustomer'],
                isproduct: widget.adminInfo['isProducts'],
                istransaction: widget.adminInfo['isTransactions'],
              ),
              SalesTab(userId: widget.adminInfo['adminId'], isAdmin: true),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget salesTab({required String adminId}) {
//   print(adminId);
//   return FutureBuilder<QuerySnapshot>(
//       future: FirebaseFirestore.instance
//           .collection('transaction')
//           .where('employee_id', isEqualTo: adminId)          
//           .get(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: Container(
//               height: 50.0,
//               width: 50.0,
//               child: CircularProgressIndicator(
//                 color: kMainColor,
//               ),
//             ),
//           );
//         } else if (snapshot.hasError) {
//           print(snapshot.error);
//           return Center(
//             child: Text(
//               'Oops an error occured.',
//               style: kProductNameStyle,
//             ),
//           );
//         }else{
//           final data = snapshot.data!.docs;
//           print(data.first);
//           List transactions = [];
//           data.forEach((element) {
//             transactions.add(element.data());
//           });
//           // print(transactions);
//           return transactions.isNotEmpty
//               ? ListView.builder(
//                   itemCount: transactions.length,
//                   shrinkWrap: true,
//                   itemBuilder: (BuildContext context, int i) {
//                     List items = transactions[i]['items'];
//                     String description = '';
//                     items.forEach((element) {
//                       description +=
//                           '${element['quantity']} X ${element['product_name']}, ';
//                     });
//                     Timestamp timestamp = transactions[i]['date'];
//                     String date = DateFormat.yMMMd().format(timestamp.toDate());
//                     return OrderTranzCard(
//                       onTap: () {
//                         Navigator.push(context,
//                             MaterialPageRoute(builder: (context) {
//                           return ReceiptScreen(data: transactions[i]);
//                         }));
//                       },
//                       date: date,
//                       price: transactions[i]['price'].toString(),
//                       employeeName: transactions[i]['employee_id'],
//                       customerName: transactions[i]['user_info']['name'],
//                       desc: description,
//                     );
//                   },
//                 )
//               : Center(
//                   child: Text(
//                     'You have\'nt made sale yet.',
//                     style: kProductNameStyle,
//                   ),
//                 );
//         } 
//       });
// }

Widget infoTab(
    {required String name, id, email, required BuildContext context}) {
  TextEditingController _nameController = TextEditingController(text: name),
      _iDController = TextEditingController(text: id),
      _emailController = TextEditingController(text: email);
  return SingleChildScrollView(
    padding: EdgeInsets.all(10.0),
    child: Container(
      height: MediaQuery.of(context).size.height,
      // width: MediaQuery.of(context).size.width * 0.45,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                TextField(
                  style: kProductNameStylePro,
                  cursorColor: kSubMainColor,
                  controller: _nameController,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: kSubMainColor,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: kMainColor,
                      ),
                    ),
                    labelText: "Full Name",
                    labelStyle: kProductNameStylePro,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  style: kProductNameStylePro,
                  controller: _emailController,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: kSubMainColor,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: kMainColor,
                      ),
                    ),
                    labelText: "Email",
                    labelStyle: kProductNameStylePro,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  style: kProductNameStylePro,
                  controller: _iDController,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: kSubMainColor,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: kMainColor,
                        ),
                      ),
                      labelText: "ID",
                      labelStyle: kProductNameStylePro),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class PermissionTab extends StatefulWidget {
  final bool isadmin,
      isinventory,
      isproduct,
      istransaction,
      ismakeCustomer,
      ismakeAdmin;
  String adminId;
  PermissionTab(
      {required this.isadmin,
      required this.isinventory,
      required this.ismakeAdmin,
      required this.ismakeCustomer,
      required this.isproduct,
      required this.istransaction,
      required this.adminId});

  @override
  _PermissionTabState createState() => _PermissionTabState();
}

class _PermissionTabState extends State<PermissionTab> {
  bool isAdmin = true,
      isInventory = false,
      isProduct = false,
      isTransaction = false,
      isMakeCustomer = false,
      isMakeAdmin = false,
      isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      isAdmin = widget.isadmin;
      isInventory = widget.isinventory;
      isMakeAdmin = widget.ismakeAdmin;
      isMakeCustomer = widget.ismakeCustomer;
      isProduct = widget.isproduct;
      isTransaction = widget.istransaction;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Container(
        padding: EdgeInsets.all(13.0),
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Column(
              children: [
                ListTile(
                  // leading: Icon(Icons.dark_mode),
                  title: Text(
                    'Administrator',
                    style: kProductNameStyle,
                  ),
                  onTap: () {
                    // Provider.of<Configs>(context, listen: false).toggleDarkMode();
                  },
                  trailing: Switch(
                    activeColor: kMainColor,
                    value: isAdmin,
                    onChanged: (status) {
                      setState(() {
                        isAdmin = status;
                        isInventory = status;
                        isProduct = status;
                        isTransaction = status;
                        isMakeAdmin = status;
                        isMakeCustomer = status;
                      });
                    },
                  ),
                ),
                ListTile(
                  // leading: Icon(Icons.dark_mode),
                  title: Text(
                    'Create and Edit products',
                    style: kProductNameStyle,
                  ),
                  onTap: () {
                    // Provider.of<Configs>(context, listen: false).toggleDarkMode();
                  },
                  trailing: Switch(
                    activeColor: kMainColor,
                    value: isProduct,
                    onChanged: isAdmin == true
                        ? null
                        : (status) {
                            setState(() {
                              isProduct = status;
                            });
                          },
                  ),
                ),
                ListTile(
                  // leading: Icon(Icons.dark_mode),
                  title: Text(
                    'Manage Inventory',
                    style: kProductNameStyle,
                  ),
                  onTap: () {},
                  trailing: Switch(
                    activeColor: kMainColor,
                    value: isInventory,
                    onChanged: isAdmin == true
                        ? null
                        : (status) {
                            setState(() {
                              isInventory = status;
                            });
                          },
                  ),
                ),
                ListTile(
                  // leading: Icon(Icons.dark_mode),
                  title: Text(
                    'View Transactions',
                    style: kProductNameStyle,
                  ),
                  onTap: () {},
                  trailing: Switch(
                    activeColor: kMainColor,
                    value: isTransaction,
                    onChanged: isAdmin == true
                        ? null
                        : (status) {
                            setState(() {
                              isTransaction = status;
                            });
                          },
                  ),
                ),
                ListTile(
                  // leading: Icon(Icons.dark_mode),
                  title: Text(
                    'Create Customers',
                    style: kProductNameStyle,
                  ),
                  onTap: () {
                    // Provider.of<Configs>(context, listen: false).toggleDarkMode();
                  },
                  trailing: Switch(
                    activeColor: kMainColor,
                    value: isMakeCustomer,
                    onChanged: isAdmin == true
                        ? null
                        : (status) {
                            setState(() {
                              isMakeCustomer = status;
                            });
                          },
                  ),
                ),
                ListTile(
                  // leading: Icon(Icons.dark_mode),
                  title: Text(
                    'Create user',
                    style: kProductNameStyle,
                  ),
                  onTap: () {
                    // Provider.of<Configs>(context, listen: false).toggleDarkMode();
                  },
                  trailing: Switch(
                    activeColor: kMainColor,
                    value: isMakeAdmin,
                    onChanged: isAdmin == true
                        ? null
                        : (status) {
                            setState(() {
                              isMakeAdmin = status;
                            });
                          },
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                onTap: () {
                  print(isProduct);
                  setState(() {
                    isLoading = true;
                  });
                  Map<String, dynamic> info = {
                    'isAdmin': isAdmin,
                    'isInventory': isInventory,
                    'isProducts': isProduct,
                    'isTransactions': isTransaction,
                    'isMakeCustomer': isMakeCustomer,
                    'isMakeAdmin': isMakeAdmin,
                  };
                  AdminCrud().updateAdmin(info, widget.adminId).then((value) {
                    setState(() {
                      isLoading = false;
                    });
                  });
                },
                child: Container(
                  height: 50.0,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: kSubMainColor,
                    borderRadius: BorderRadius.circular(10.0),
                    // border: Border.all(color: kMainColor),
                  ),
                  child: Center(
                    child: Text(
                      'Update',
                      style: kDrawerTextStyle2,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
