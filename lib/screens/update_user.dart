import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop/customers/barrel.dart';
import 'package:viraeshop/customers/customers_bloc.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/components/ui_components/delete_popup.dart';
import 'package:viraeshop_admin/screens/customers/customer_info.dart';
import 'package:viraeshop_admin/screens/customers/customer_provider.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/screens/customers/tabWidgets.dart';
import 'package:viraeshop_admin/screens/messages_screen/messages.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';

import '../configs/configs.dart';
import 'general_provider.dart';
import 'home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum Operation {
  delete,
  update,
  none,
}

class UpdateUser extends StatefulWidget {
  final Map userInfo;
  final String userId;
  final String role;
  const UpdateUser(
      {Key? key,
      required this.userInfo,
      required this.userId,
      required this.role})
      : super(key: key);

  @override
  _UpdateUserState createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  TextEditingController nameController = TextEditingController();
  TextEditingController walletController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var default_role = 'Customer';
  var selected_role = '';
  final List _myList = ['general', 'agents', 'architect'];

  var default_verification = 'not-verified';
  var selected_verification = '';
  final List _verificationList = ['not-verified', 'verified'];

  var default_activity = 'not-active';
  var selected_activity = '';
  final List _activityList = ['not-active', 'active'];

  bool isLoading = false;

  var currdate = DateTime.now();
  AdminCrud adminCrud = AdminCrud();
  GeneralCrud generalCrud = GeneralCrud();
  bool isDeleteCustomer = Hive.box('adminInfo').get('isDeleteCustomer');
  bool isEditCustomer =
      Hive.box('adminInfo').get('isEditCustomer', defaultValue: false);
  final jWTToken = Hive.box('adminInfo').get('token');
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
  List<Widget> tabWidgets = [];
  Operation currentOperation = Operation.none;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabWidgets = [
      CustomerInfoScreen(
        info: widget.userInfo,
      ),
      SalesTab(userId: widget.userId),
      OrdersTab(userId: widget.userId),
    ];
    if (widget.userInfo['role'] == 'agents' && isEditCustomer) {
      _tabs.add(
        const Tab(
          text: 'Account',
        ),
      );
      tabWidgets.add(walletTab());
    }
    nameController.text = widget.userInfo['name'];
    _emailController.text = widget.userInfo['email'];
    phoneController.text = widget.userInfo['mobile'];
    walletController.text = widget.userInfo['wallet'].toString() ?? '';
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<CustomerProvider>(context, listen: false)
          .updateWallet(widget.userInfo['wallet'] ?? 0);
    });
    default_role = widget.userInfo['role'];
    selected_role = widget.userInfo['role'];
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(color: kMainColor),
      child: SafeArea(
        child: DefaultTabController(
          length: _tabs.length,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  final customerBloc = BlocProvider.of<CustomersBloc>(context);
                  if (customerBloc.state is! FetchedCustomersState) {
                    customerBloc.add(
                      GetCustomersEvent(query: widget.role, token: jWTToken),
                    );
                  }
                  Navigator.pop(context);
                },
                icon: const Icon(FontAwesomeIcons.chevronLeft),
                color: kSubMainColor,
              ),
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
                if (isEditCustomer)
                  Consumer<GeneralProvider>(builder: (context, user, childs) {
                    return IconButton(
                      onPressed: () {
                        Provider.of<GeneralProvider>(context, listen: false)
                            .onUserEdit(!user.isEditUser);
                      },
                      icon: Icon(
                        user.isEditUser ? Icons.done : Icons.edit,
                      ),
                      color: kSubMainColor,
                      iconSize: 20.0,
                    );
                  }),
                const SizedBox(
                  width: 5.0,
                ),
                if (isDeleteCustomer)
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return DeletePopup(
                            onDelete: () async {
                              final customerBloc =
                                  BlocProvider.of<CustomersBloc>(context);
                              setState(() {
                                isLoading = true;
                                currentOperation = Operation.delete;
                              });
                              Navigator.pop(context);
                              Box customerBox = Hive.box('customer');
                              if (customerBox.isNotEmpty &&
                                  customerBox.get('id') == widget.userId) {
                                customerBox.clear();
                              }
                              customerBloc.add(
                                DeleteCustomerEvent(
                                  token: jWTToken,
                                  customerId: widget.userId,
                                ),
                              );
                            },
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
            body: BlocListener<CustomersBloc, CustomerState>(
              listener: (context, state) {
                if (state is RequestFinishedCustomerState) {
                  if (currentOperation == Operation.delete) {
                    setState(() {
                      currentOperation = Operation.none;
                      isLoading = false;
                    });
                    toast(context: context, title: 'Deleted successfully');
                  } else if (currentOperation == Operation.update) {
                    setState(() {
                      currentOperation = Operation.none;
                      isLoading = false;
                      Provider.of<CustomerProvider>(context, listen: false)
                          .updateWallet(
                        num.parse(walletController.text),
                        true,
                      );
                    });
                    toast(context: context, title: 'Updated successfully');
                  }
                } else if (state is OnErrorCustomerState) {
                  setState(() {
                    isLoading = false;
                  });
                  snackBar(
                    text: state.message,
                    context: context,
                    color: kRedColor,
                    duration: 600,
                  );
                }
              },
              child: TabBarView(
                children: tabWidgets,
              ),
            ),
          ),
        ),
      ),
    );
  }

  walletTab() {
    final onEdit =
        Hive.box('adminInfo').get('isEditCustomer', defaultValue: false);
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Stack(
        children: [
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
                      Consumer<CustomerProvider>(
                          builder: (context, customer, any) {
                        return Text(
                          '${customer.wallet.toString()}৳',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 70,
                            color: kSelectedTileColor,
                          ),
                        );
                      }),
                    ],
                  ),
                  InkWell(
                    onTap: onEdit == false
                        ? null
                        : () {
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
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Consumer<CustomerProvider>(
                                        builder: (context, customer, any) {
                                      return InkWell(
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 58,
                                          decoration: BoxDecoration(
                                              color:
                                                  kSelectedTileColor, //Theme.of(context).accentColor,
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: const Center(
                                            child: Text(
                                              "Add",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          num newBalance = customer.wallet +
                                              num.parse(walletController.text);
                                          Navigator.pop(context);
                                          setState(() {
                                            currentOperation = Operation.update;
                                            isLoading = true;
                                          });
                                          final customerBloc =
                                              BlocProvider.of<CustomersBloc>(
                                            context,
                                          );
                                          customerBloc.add(
                                            UpdateCustomerEvent(
                                              customerId: widget.userId,
                                              customerModel: {
                                                'wallet': newBalance,
                                              },
                                              token: jWTToken,
                                            ),
                                          );
                                        },
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            );
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
                        children: const [
                          Text(
                            'Update Balance',
                            style: TextStyle(fontSize: 20, color: Colors.white),
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
        builder: (context, constraints) => SizedBox(
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
                              var updUser = {};
                              setState(() {
                                isLoading = false;
                              });
                              myLoader(visibility: !isLoading);
                              // print(jsonEncode(upd_user) + widget.user_id);
                              if (widget.userInfo['role'] == 'agents') {
                                setState(() {
                                  updUser = {
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
                                      cusData: updUser,
                                      collection: widget.userInfo['agents'])
                                  .then((val) {
                                if (val) {
                                  setState(() {
                                    isLoading = true;
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
                                    isLoading = true;
                                  });
                                  showMyDialog(
                                      '$selected_role Not Updated', context);
                                }
                              });
                            } else {
                              setState(() {
                                isLoading = true;
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
