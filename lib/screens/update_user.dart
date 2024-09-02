import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/screens/customers/wallet_screen.dart';
import 'package:viraeshop_bloc/customers/barrel.dart';
import 'package:viraeshop_bloc/customers/customers_bloc.dart';
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
      tabWidgets.add(WalletScreen(
        customerId: widget.userId,
      ));
    }
    nameController.text = widget.userInfo['name'];
    _emailController.text = widget.userInfo['email'];
    phoneController.text = widget.userInfo['mobile'];
    walletController.text = widget.userInfo['wallet'].toString() ?? '';
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<CustomerProvider>(context, listen: false).updateAmounts(
        wallet: widget.userInfo['wallet'] ?? 0,
        creditBalance: widget.userInfo['creditBalance'] ?? 0,
        alertLimit: widget.userInfo['alertLimit'] ?? 0,
        accountLimit: widget.userInfo['accountLimit'] ?? 0,
      );
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
                if (state is RequestFinishedCustomerState &&
                    currentOperation == Operation.delete) {
                  setState(() {
                    currentOperation = Operation.none;
                    isLoading = false;
                  });
                  toast(context: context, title: 'Deleted successfully');
                } else if (state is OnErrorCustomerState &&
                    currentOperation == Operation.delete) {
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
}
