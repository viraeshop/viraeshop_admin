import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/customers/customer_info.dart';
import 'package:viraeshop_admin/screens/customers/tabWidgets.dart';
import 'package:viraeshop_admin/screens/messages_screen/messages.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';

import 'home_screen.dart';

class UpdateUser extends StatefulWidget {
  final Map userInfo;
  final String userId;
 const  UpdateUser({Key? key, required this.userInfo, required this.userId})
      : super(key: key);

  @override
  _UpdateUserState createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  TextEditingController nameController = TextEditingController();
  TextEditingController walletController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var default_role = 'Customer';
  var selected_role = '';
  List _myList = ['general', 'agents', 'architect'];

  var default_verification = 'not-verified';
  var selected_verification = '';
  List _verificationList = ['not-verified', 'verified'];

  var default_activity = 'not-active';
  var selected_activity = '';
  List _activityList = ['not-active', 'active'];

  bool showFields = false;

  var currdate = DateTime.now();
  AdminCrud adminCrud = AdminCrud();
  GeneralCrud generalCrud = GeneralCrud();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      print(jsonEncode(widget.userInfo));
      nameController.text = widget.userInfo['name'];
      _emailController.text = widget.userInfo['email'];
      phoneController.text = widget.userInfo['mobile'];
      //passwordController.text = widget.userInfo['password'];
      walletController.text = widget.userInfo['wallet'].toString();
      default_role = widget.userInfo['role'];
      selected_role = widget.userInfo['role'];
      // default_verification = current_user['verification_status'];
      selected_verification = 'verified';
      //current_user['verification_status'];
      // default_activity = current_user['activity_status'];
      // selected_activity = current_user['activity_status'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final _tabs = <Tab>[
      const Tab(
        text: 'Info',
      ),
      const Tab(
        text: 'Sales',
      ),
      const Tab(
        text: 'Orders',
      ),
    ];
    List<Widget> tabWidgets = [
      CustomerInfoScreen(
        info: widget.userInfo,
      ),
      SalesTab(userId: widget.userId),
      OrdersTab(userId: widget.userId),
    ];
    if (widget.userInfo['role'] == 'agents') {
      _tabs.add(
        const Tab(
          text: 'Account',
        ),
      );
      tabWidgets.add(walletTab());
    }
    return ModalProgressHUD(
      inAsyncCall: showFields,
      progressIndicator: const CircularProgressIndicator(color: kMainColor),
      child: SafeArea(
        child: DefaultTabController(
          length: _tabs.length,
          child: Scaffold(
            // floatingActionButton: FloatingActionButton(
            //   onPressed: () {
            //     FirebaseFirestore.instance
            //         .collection('messages')
            //         .doc(widget.user_id)
            //         .set({
            //       'name': current_user['fullname'],
            //       'userId': widget.user_id,
            //       'email': current_user['email'],
            //     });
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => Message(
            //             name: current_user['fullname'], userId: widget.user_id),
            //       ),
            //     );
            //   },
            //   backgroundColor: kMainColor,
            //   child: Icon(
            //     Icons.message,
            //     color: kBackgroundColor,
            //   ),
            // ),
            appBar: AppBar(
              bottom: TabBar(
                tabs: _tabs,
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
              iconTheme: const IconThemeData(color: kSelectedTileColor),
              elevation: 0.0,
              backgroundColor: kBackgroundColor,
              title: const Text(
                'Update user',
                style: kAppBarTitleTextStyle,
              ),
              centerTitle: true,
              titleTextStyle: kTextStyle1,
              actions: [
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete Customer'),
                          content: const Text(
                            'Are you sure you want to remove this customer?',
                            softWrap: true,
                            style: kSourceSansStyle,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                setState(() {
                                  showFields = true;
                                });
                                Navigator.pop(context);
                                await FirebaseFirestore.instance
                                    .collection(widget.userInfo['role'])
                                    .doc(widget.userId)
                                    .delete()
                                    .then((value) {
                                  setState(() {
                                    showFields = false;
                                  });
                                  Navigator.pushNamedAndRemoveUntil(context,
                                      HomeScreen.path, (route) => false);
                                });
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
              children: tabWidgets,
            ),
          ),
        ),
      ),
    );
  }

  walletTab() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Stack(
        children: [
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: ProdBtn(context: context, text: 'Click Me'),
          // ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'CURRENT ACCOUNT BALANCE',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: kProductCardColor),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text(
                      //   '\$',
                      //   textAlign: TextAlign.center,
                      //   style: TextStyle(
                      //       fontSize: 40, color: kSelectedTileColor),
                      // ),
                      StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('customers')
                              .doc(widget.userInfo['userId'])
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final data = snapshot.data;
                              return Text(
                                '${data!.get('wallet').toString()}৳',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 70, color: kSelectedTileColor),
                              );
                            }
                            return const Text(
                              '৳',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 70, color: kSelectedTileColor),
                            );
                          }),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      // Update Wallet
                      popDialog(
                          title: 'Add Funds',
                          context: context,
                          widget: SingleChildScrollView(
                            child: Column(
                              // shrinkWrap: true,
                              children: [
                                TextField(
                                  controller: walletController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Amount",
                                    hintText: "",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                InkWell(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 58,
                                    decoration: BoxDecoration(
                                        color:
                                            kSelectedTileColor, //Theme.of(context).accentColor,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Add",
                                          style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.white),
                                        )
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    print(widget.userId);
                                    Navigator.pop(context);
                                    setState(() {
                                      showFields = !showFields;
                                    });
                                    adminCrud
                                        .wallet(
                                      widget.userInfo['userId'],
                                      num.parse(walletController.text),
                                    )
                                        .then((successfull) {
                                      // Navigator.pop(context);
                                      setState(() {
                                        showFields = !showFields;
                                        widget.userInfo['wallet'] =
                                            double.parse(walletController.text);
                                      });
                                      showMyDialog(
                                          'Funds Update Successfull', context);
                                      // if (successfull) {
                                      //   popDialog(
                                      //       title: 'Success',
                                      //       widget: Text(
                                      //           'Funds Added Successfull, reload page'));
                                      // } else {
                                      //   popDialog(
                                      //       title: 'Success',
                                      //       widget: Text(
                                      //           'Could Not Add Funds'));
                                      // }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ));
                    },
                    child: Container(
                      width: 200,
                      height: 53,
                      decoration: BoxDecoration(
                          border: Border.all(color: kMainColor, width: 1),
                          color: kMainColor, //Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(5)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Update Balance',
                            style: const TextStyle(fontSize: 20, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Page One
  pageOne() {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) => Container(
          width: constraints.maxWidth > 600
              ? MediaQuery.of(context).size.width * 0.4
              : null,
          height: MediaQuery.of(context).size.height,
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
                        // current_user['role'] == 'agent'
                        //     ? Row(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //           Padding(
                        //             padding: const EdgeInsets.all(3.0),
                        //             child: Container(
                        //                 decoration: BoxDecoration(
                        //                   borderRadius:
                        //                       BorderRadius.circular(15),
                        //                   color: kMainColor,
                        //                 ),
                        //                 child: Padding(
                        //                   padding: const EdgeInsets.all(12.0),
                        //                   child: Text(
                        //                     'Wallet: \$${current_user['wallet']}',
                        //                     style: TextStyle(
                        //                         color: Colors.white),
                        //                   ),
                        //                 )),
                        //           ),
                        //           GestureDetector(
                        //             onTap: () {
                        //               popDialog(
                        //                   title: 'Add Funds',
                        //                   context: context,
                        //                   widget: SingleChildScrollView(
                        //                     child: Column(
                        //                       // shrinkWrap: true,
                        //                       children: [
                        //                         TextField(
                        //                           controller:
                        //                               walletController,
                        //                           keyboardType:
                        //                               TextInputType.number,
                        //                           decoration: InputDecoration(
                        //                               labelText: "Amount",
                        //                               hintText: "",
                        //                               border: OutlineInputBorder(
                        //                                   borderRadius:
                        //                                       BorderRadius
                        //                                           .circular(
                        //                                               15))),
                        //                         ),
                        //                         SizedBox(height: 20),
                        //                         InkWell(
                        //                           child: Container(
                        //                             width:
                        //                                 MediaQuery.of(context)
                        //                                     .size
                        //                                     .width,
                        //                             height: 58,
                        //                             decoration: BoxDecoration(
                        //                                 color:
                        //                                     kSelectedTileColor, //Theme.of(context).accentColor,
                        //                                 borderRadius:
                        //                                     BorderRadius
                        //                                         .circular(
                        //                                             15)),
                        //                             child: Row(
                        //                               mainAxisAlignment:
                        //                                   MainAxisAlignment
                        //                                       .center,
                        //                               crossAxisAlignment:
                        //                                   CrossAxisAlignment
                        //                                       .center,
                        //                               children: [
                        //                                 Text(
                        //                                   "Add",
                        //                                   style: TextStyle(
                        //                                       fontSize: 20,
                        //                                       color: Colors
                        //                                           .white),
                        //                                 )
                        //                               ],
                        //                             ),
                        //                           ),
                        //                           onTap: () async {
                        //                             print(widget.user_id);
                        //                             adminCrud.updateWallet(
                        //                                 {
                        //                                   'id':
                        //                                       widget.user_id,
                        //                                   'email':
                        //                                       current_user[
                        //                                           'email']
                        //                                 },
                        //                                 double.parse(
                        //                                     walletController
                        //                                         .text)).then(
                        //                                 (successfull) {
                        //                               Navigator.pop(context);
                        //                               showMyDialog(
                        //                                   'Funds Update Successfull, reload page',
                        //                                   context);
                        //                               // if (successfull) {
                        //                               //   popDialog(
                        //                               //       title: 'Success',
                        //                               //       widget: Text(
                        //                               //           'Funds Added Successfull, reload page'));
                        //                               // } else {
                        //                               //   popDialog(
                        //                               //       title: 'Success',
                        //                               //       widget: Text(
                        //                               //           'Could Not Add Funds'));
                        //                               // }
                        //                             });
                        //                           },
                        //                         ),
                        //                       ],
                        //                     ),
                        //                   ));
                        //             },
                        //             child: CircleAvatar(
                        //               child: Icon(Icons.add),
                        //             ),
                        //           )
                        //         ],
                        //       )
                        //     : Container(),
                        const SizedBox(height: 20),
                        SizedBox(
                            height: 170,
                            width: 170,
                            child: Stack(
                              alignment: AlignmentDirectional.bottomCenter,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(13.0),
                                  child: Container(
                                    // color: Colors.red,
                                    width: 200,
                                    height: 200,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'assets/default.jpg'),
                                            fit: BoxFit.contain)),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: CircleAvatar(
                                    backgroundColor: kSelectedTileColor,
                                    child: Icon(
                                      Icons.add,
                                      size: 30,
                                    ),
                                  ),
                                )
                              ],
                            )),
                        // Second item

                        Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Row(children: [
                            MyIcons(icon: Icons.call),
                            MyIcons(icon: Icons.sms),
                            MyIcons(icon: Icons.email),
                            // MyIcons(
                            //     icon: Icons.location_city,
                            //     onClick: () => print('Hello World'))
                          ]),
                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                TextField(
                                  controller: nameController,
                                  decoration: const InputDecoration(
                                    labelText: "Full Name",
                                    hintText: "",
                                    // border: OutlineInputBorder(
                                    //     borderRadius:
                                    //         BorderRadius.circular(15))
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const TextField(
                                  // controller: fullnameController,
                                  decoration: InputDecoration(
                                    labelText: "Address",
                                    hintText: "",
                                    // border: OutlineInputBorder(
                                    //     borderRadius:
                                    //         BorderRadius.circular(15))
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    labelText: "Email",
                                    hintText: "",
                                    // border: OutlineInputBorder(
                                    //     borderRadius: BorderRadius.circular(15))
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextField(
                                  controller: phoneController,
                                  decoration: const InputDecoration(
                                    labelText: "Phone",
                                    hintText: "",
                                    // border: OutlineInputBorder(
                                    //     borderRadius: BorderRadius.circular(15))
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        bottomCard(
                          context: context,
                          text: "Save",
                          onTap: () async {
                            if (nameController.text != '' &&
                                _emailController.text != '' &&
                                phoneController.text != '' &&
                                passwordController.text != '' &&
                                selected_verification != '') {
                              //
                              var upd_user = {};
                              setState(() {
                                showFields = false;
                              });
                              myLoader(visibility: !showFields);
                              // print(jsonEncode(upd_user) + widget.user_id);
                              if (widget.userInfo['role'] == 'agents') {
                                setState(() {
                                  upd_user = {
                                    'name': nameController.text,
                                    'email': _emailController.text,
                                    'phone': phoneController.text,
                                  };
                                });
                              } else {
                                // Not agent, Set, another

                              }
                              // Update Here
                              adminCrud
                                  .updateCustomer(
                                      cid: widget.userId,
                                      cusData: upd_user,
                                      collection: widget.userInfo['agents'])
                                  .then((val) {
                                if (val) {
                                  setState(() {
                                    showFields = true;
                                  });
                                  popDialog(
                                      widget: Text(
                                        '$selected_role Update Successfull',
                                        textAlign: TextAlign.center,
                                      ),
                                      title: 'Success',
                                      context: context);
                                } else {
                                  setState(() {
                                    showFields = true;
                                  });
                                  showMyDialog(
                                      '$selected_role Not Updated', context);
                                }
                              });
                            } else {
                              setState(() {
                                showFields = true;
                              });
                              showMyDialog('Fields Cannot Be Empty', context);
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
