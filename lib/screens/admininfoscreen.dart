import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/allusers.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';


import 'customers/tabWidgets.dart';
import 'home_screen.dart';


class EditUserScreen extends StatefulWidget {
  final adminInfo;
  const EditUserScreen({required this.adminInfo});
  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  bool isLoading = false;
  bool isDeleteEmployee = Hive.box('adminInfo').get('isDeleteEmployee');
  List<Tab> tabs = [
    const Tab(text: 'Info'),
    const Tab(text: 'Permissions'),
    const Tab(text: 'Sales'),
  ];
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(color: kMainColor),
      child: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: kBackgroundColor,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                FontAwesomeIcons.chevronLeft,
                color: kSubMainColor,
              ),
              iconSize: 15.0,
            ),
            title: const Text(
              'Edit user',
              style: kProductNameStylePro,
            ),
            centerTitle: true,
            bottom: TabBar(
              tabs: tabs,
              indicatorColor: kMainColor,
              labelColor: kMainColor,
              unselectedLabelColor: kSubMainColor,
              labelStyle: const TextStyle(
                color: kMainColor,
                fontSize: 15.0,
                letterSpacing: 1.3,
                fontFamily: 'Montserrat',
              ),
              unselectedLabelStyle: kProductNameStylePro,
            ),
            actions: [
              !isDeleteEmployee ? const SizedBox() : IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Delete User'),
                        content: const Text(
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
                              try{
                                Navigator.pop(context);
                                await NetworkUtility.deleteEmployee(widget.adminInfo['adminId']);
                                Future.delayed(const Duration(milliseconds: 0), (){
                                  Navigator.popUntil(context, ModalRoute.withName(AllUserScreen.path));
                                });
                              }on FirebaseException catch (e){
                                if(kDebugMode){
                                  print(e.message);
                                }
                                toast(context: context, title: e.message!, color: kRedColor);
                              }finally{
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                            child: const Text(
                              'Yes',
                              softWrap: true,
                              style: kSourceSansStyle,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
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
                icon: const Icon(
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
                isAdmin: widget.adminInfo['isAdmin'],
                isinventory: widget.adminInfo['isInventory'],
                isMakeAdmin: widget.adminInfo['isMakeAdmin'],
                isMakeCustomer: widget.adminInfo['isMakeCustomer'],
                isproduct: widget.adminInfo['isProducts'],
                istransaction: widget.adminInfo['isTransactions'],
                isDeleteCustomer: widget.adminInfo['isDeleteCustomer'],
                isDeleteEmployee: widget.adminInfo['isDeleteEmployee'],
                isManageDue: widget.adminInfo['isManageDue'],
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
  TextEditingController nameController = TextEditingController(text: name),
      iDController = TextEditingController(text: id),
      emailController = TextEditingController(text: email);
  return SingleChildScrollView(
    padding: const EdgeInsets.all(10.0),
    child: SizedBox(
      height: MediaQuery.of(context).size.height,
      // width: MediaQuery.of(context).size.width * 0.45,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                TextField(
                  style: kProductNameStylePro,
                  cursorColor: kSubMainColor,
                  controller: nameController,
                  decoration: const InputDecoration(
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
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  style: kProductNameStylePro,
                  controller: emailController,
                  decoration: const InputDecoration(
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
                const SizedBox(
                  height: 20,
                ),
                // TextField(
                //   style: kProductNameStylePro,
                //   controller: iDController,
                //   decoration: const InputDecoration(
                //       enabledBorder: UnderlineInputBorder(
                //         borderSide: BorderSide(
                //           color: kSubMainColor,
                //         ),
                //       ),
                //       focusedBorder: UnderlineInputBorder(
                //         borderSide: BorderSide(
                //           color: kMainColor,
                //         ),
                //       ),
                //       labelText: "ID",
                //       labelStyle: kProductNameStylePro),
                // ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class PermissionTab extends StatefulWidget {
  final bool? isAdmin,
      isinventory,
      isproduct,
      istransaction,
      isMakeCustomer,
      isDeleteCustomer,
      isDeleteEmployee,
      isManageDue,
      isMakeAdmin;
  String adminId;
  PermissionTab(
      {required this.isAdmin,
      required this.isinventory,
      required this.isMakeAdmin,
      required this.isMakeCustomer,
      required this.isproduct,
      required this.istransaction,
      required this.isDeleteCustomer,
      required this.isDeleteEmployee,
      required this.isManageDue,
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
      isLoading = false,
      isDeleteCustomer = false,
      isDeleteEmployee = false,
      isManageDue = false
  ;
  @override
  void initState() {
    // TODO: implement initState
      isAdmin = widget.isAdmin!;
      isInventory = widget.isinventory!;
      isMakeAdmin = widget.isMakeAdmin!;
      isMakeCustomer = widget.isMakeCustomer!;
      isProduct = widget.isproduct!;
      isTransaction = widget.istransaction!;
      isManageDue = widget.isManageDue ?? false;
      isDeleteEmployee = widget.isDeleteEmployee ?? false;
      isDeleteCustomer = widget.isDeleteCustomer ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Container(
        padding: const EdgeInsets.all(13.0),
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Column(
              children: [
                ListTile(
                  // leading: Icon(Icons.dark_mode),
                  title: const Text(
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
                        isDeleteEmployee = status;
                        isDeleteCustomer = status;
                        isManageDue = status;
                      });
                    },
                  ),
                ),
                ListTile(
                  // leading: Icon(Icons.dark_mode),
                  title: const Text(
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
                  title: const Text(
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
                  title: const Text(
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
                  title: const Text(
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
                  title: const Text(
                    'Create Employee',
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
                ListTile(
                  // leading: Icon(Icons.dark_mode),
                  title: const Text(
                    'Delete Employee',
                    style: kProductNameStyle,
                  ),
                  onTap: () {
                    // Provider.of<Configs>(context, listen: false).toggleDarkMode();
                  },
                  trailing: Switch(
                    activeColor: kMainColor,
                    value: isDeleteEmployee,
                    onChanged: isAdmin == true
                        ? null
                        : (status) {
                      setState(() {
                        isDeleteEmployee = status;
                      });
                    },
                  ),
                ),
                ListTile(
                  // leading: Icon(Icons.dark_mode),
                  title: const Text(
                    'Delete Customer',
                    style: kProductNameStyle,
                  ),
                  onTap: () {
                    // Provider.of<Configs>(context, listen: false).toggleDarkMode();
                  },
                  trailing: Switch(
                    activeColor: kMainColor,
                    value: isDeleteCustomer,
                    onChanged: isAdmin == true
                        ? null
                        : (status) {
                      setState(() {
                        isDeleteCustomer = status;
                      });
                    },
                  ),
                ),
                ListTile(
                  // leading: Icon(Icons.dark_mode),
                  title: const Text(
                    'Manage Due',
                    style: kProductNameStyle,
                  ),
                  onTap: () {
                    // Provider.of<Configs>(context, listen: false).toggleDarkMode();
                  },
                  trailing: Switch(
                    activeColor: kMainColor,
                    value: isManageDue,
                    onChanged: isAdmin == true
                        ? null
                        : (status) {
                      setState(() {
                        isManageDue = status;
                      });
                    },
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                onTap: () async{
                  if (kDebugMode) {
                    print(isProduct);
                  }
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
                    'isDeleteCustomer': isDeleteCustomer,
                    'isManageDue': isManageDue,
                    'isDeleteEmployee': isDeleteEmployee,
                  };
                  print(info);
                  try{
                    await NetworkUtility.updateAdmin(info, widget.adminId);
                  }on FirebaseException catch (e){
                    if(kDebugMode){
                      print('error: $e');
                    }
                    snackBar(text: e.message!, context: context, color: kRedColor, duration: 30);
                  }finally{
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                child: Container(
                  height: 50.0,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: kSubMainColor,
                    borderRadius: BorderRadius.circular(10.0),
                    // border: Border.all(color: kMainColor),
                  ),
                  child: const Center(
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
