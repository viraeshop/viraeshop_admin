import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/screens/advert/advert_screen.dart';
import 'package:viraeshop_api/models/suppliers/suppliers.dart';
import 'package:viraeshop_bloc/admin/admin_bloc.dart';
import 'package:viraeshop_bloc/admin/admin_event.dart';
import 'package:viraeshop_bloc/admin/admin_state.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/admins/admin_provider.dart';
import 'package:viraeshop_admin/screens/admins/allusers.dart';
import 'package:viraeshop_admin/screens/admins/authenticate_popup.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';
import 'package:viraeshop_api/models/admin/admins.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_bloc/suppliers/barrel.dart';

import '../customers/tabWidgets.dart';

class EditUserScreen extends StatefulWidget {
  final Map<String, dynamic> adminInfo;
  final bool selfAdmin;
  const EditUserScreen(
      {Key? key, required this.adminInfo, this.selfAdmin = false})
      : super(key: key);
  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  bool isLoading = false;
  bool isDeleteEmployee = Hive.box('adminInfo').get('isDeleteEmployee');
  List<Tab> tabs = [
    const Tab(text: 'Info'),
    const Tab(text: 'Orders'),
    const Tab(text: 'Sales'),
  ];
  @override
  void initState() {
    // TODO: implement initState
    if (!widget.selfAdmin) {
      tabs.add(const Tab(text: 'Permissions'));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is RequestFinishedAdminState &&
            state.requestType == 'delete') {
          setState(() {
            isLoading = false;
          });
          final adminBloc = BlocProvider.of<AdminBloc>(context);
          final jWTToken = Hive.box('adminInfo').get('token');
          adminBloc.add(GetAdminsEvent(token: jWTToken));
          Navigator.pop(context);
        } else if (state is RequestFinishedAdminState &&
            state.requestType == 'update') {
          toast(
            context: context,
            title: state.response.message,
          );
        } else if (state is OnErrorAdminState) {
          setState(() {
            isLoading = false;
          });
          snackBar(
            text: state.message,
            context: context,
            color: kRedColor,
          );
        }
      },
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: const CircularProgressIndicator(color: kMainColor),
        child: DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            backgroundColor: kBackgroundColor,
            appBar: AppBar(
              backgroundColor: kBackgroundColor,
              leading: IconButton(
                onPressed: () {
                  final adminBloc = BlocProvider.of<AdminBloc>(context);
                  final jWTToken = Hive.box('adminInfo').get('token');
                  adminBloc.add(GetAdminsEvent(token: jWTToken));
                  Navigator.pop(context);
                },
                icon: const Icon(
                  FontAwesomeIcons.chevronLeft,
                  color: kSubMainColor,
                ),
                iconSize: 15.0,
              ),
              title: Text(
                !widget.selfAdmin ? 'Edit user' : 'User Profile',
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
                if (!widget.selfAdmin)
                  if (isDeleteEmployee)
                    IconButton(
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
                                    Navigator.pop(context);
                                    final adminBloc =
                                        BlocProvider.of<AdminBloc>(context);
                                    final jWTToken =
                                        Hive.box('adminInfo').get('token');
                                    adminBloc.add(DeleteAdminEvent(
                                        token: jWTToken,
                                        adminId: widget.adminInfo['adminId']));
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
                      color: kRedColor,
                      iconSize: 20.0,
                    ),
              ],
            ),
            body: SafeArea(
              child: TabBarView(
                children: [
                  InfoTab(
                    email: widget.adminInfo['email'],
                    name: widget.adminInfo['name'],
                    isActive: widget.adminInfo['active'],
                    isSelf: widget.selfAdmin,
                    adminId: widget.adminInfo['adminId'],
                    supplier: widget.adminInfo['Suppliers'] ?? [],
                  ),
                  OrdersTab(
                    userId: widget.adminInfo['adminId'],
                  ),
                  SalesTab(userId: widget.adminInfo['adminId'], isAdmin: true),
                  if (!widget.selfAdmin)
                    PermissionTab(
                      adminModel: AdminModel.fromJson(widget.adminInfo),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InfoTab extends StatefulWidget {
  final String name;
  final String email;
  final String adminId;
  final bool isActive;
  final bool isSelf;
  final List supplier;
  const InfoTab({
    required this.name,
    required this.adminId,
    required this.email,
    required this.isActive,
    required this.isSelf,
    required this.supplier,
    Key? key,
  }) : super(key: key);

  @override
  State<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  final ScrollController _scrollController = ScrollController();
  late TextEditingController nameController;
  late TextEditingController emailController;
  bool isActive = true;
  List<Suppliers> suppliers = [];
  List<String?> supplierId = [];
  bool onErrorSupplier = false;
  bool isLoading = false;
  bool isAdmin = Hive.box('adminInfo').get('isAdmin');
  @override
  void initState() {
    // TODO: implement initState

    final supplierBloc = BlocProvider.of<SuppliersBloc>(context);
    final token = Hive.box('adminInfo').get('token');
    supplierBloc.add(
      GetSuppliersEvent(
        token: token,
      ),
    );
    if (widget.supplier.isNotEmpty) {
      supplierId = widget.supplier
          .map((supplier) => supplier['supplierId']?.toString())
          .toList();
    }
    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
    isActive = widget.isActive;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<AdminProvider>(context, listen: false)
          .updateName(widget.name);
      Provider.of<AdminProvider>(context, listen: false)
          .updateEmail(widget.email);
      Provider.of<AdminProvider>(context, listen: false)
          .saveExistingEmail(widget.email);
      Provider.of<AdminProvider>(context, listen: false)
          .updateActive(widget.isActive);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AdminBloc, AdminState>(
          listener: (context, state) {
            if (state is RequestFinishedAdminState &&
                state.requestType == 'update') {
              setState(() {
                isLoading = false;
              });
              final adminBloc = BlocProvider.of<AdminBloc>(context);
              final jWTToken = Hive.box('adminInfo').get('token');
              adminBloc.add(GetAdminsEvent(token: jWTToken));
            } else if (state is OnErrorAdminState) {
              setState(() {
                isLoading = false;
              });
              snackBar(
                text: state.message,
                context: context,
                color: kRedColor,
              );
            } else if (state is RequestFinishedAdminState &&
                state.requestType == 'update') {
              setState(() {
                isLoading = false;
              });
              snackBar(
                text: state.response.message,
                context: context,
                duration: 600,
              );
            }
          },
        ),
        BlocListener<SuppliersBloc, SupplierState>(
          listener: (context, state) {
            if (state is FetchedSuppliersState) {
              if (kDebugMode) {
                print(state.supplierList.length);
              }
              setState(() {
                onErrorSupplier = false;
                suppliers = state.supplierList;
              });
            } else if (state is OnErrorSupplierState) {
              setState(() {
                onErrorSupplier = true;
              });
              snackBar(
                text: state.message,
                context: context,
                color: kRedColor,
              );
            }
          },
        ),
      ],
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: const CircularProgressIndicator(
          color: kNewMainColor,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            // width: MediaQuery.of(context).size.width * 0.45,
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                TextField(
                  style: kProductNameStylePro,
                  cursorColor: kSubMainColor,
                  controller: nameController,
                  readOnly: widget.isSelf,
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
                  onChanged: (value) {
                    Provider.of<AdminProvider>(context, listen: false)
                        .updateName(value);
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  style: kProductNameStylePro,
                  controller: emailController,
                  readOnly: widget.isSelf,
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
                  onChanged: (value) {
                    Provider.of<AdminProvider>(context, listen: false)
                        .updateEmail(value);
                  },
                ),
                const SizedBox(
                  height: 40,
                ),
                if (suppliers.isNotEmpty && isAdmin && !widget.isSelf)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: suppliers.map((supplier) {
                            return CheckboxListTile(
                              isThreeLine: true,
                              title: Text(
                                supplier.businessName,
                                style: kProductNameStylePro.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Text(
                                supplier.address,
                                style: kProductNameStylePro,
                              ),
                              value: supplierId.contains(supplier.supplierId),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    supplierId.add(supplier.supplierId);
                                  } else {
                                    supplierId.remove(supplier.supplierId);
                                  }
                                  isLoading = true;
                                });
                                if (value == true) {
                                  final adminBloc =
                                      BlocProvider.of<AdminBloc>(context);
                                  final token =
                                      Hive.box('adminInfo').get('token');
                                  adminBloc.add(
                                    AddSupplierStaff(
                                      admin: {
                                        'adminId': widget.adminId,
                                        'supplierId': supplier.supplierId,
                                      },
                                      token: token,
                                    ),
                                  );
                                } else {
                                  final adminBloc =
                                      BlocProvider.of<AdminBloc>(context);
                                  final token =
                                      Hive.box('adminInfo').get('token');
                                  adminBloc.add(
                                    RemoveSupplierStaff(
                                      admin: {
                                        'adminId': widget.adminId,
                                        'supplierId': supplier.supplierId,
                                      },
                                      token: token,
                                    ),
                                  );
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  )
                else if (suppliers.isEmpty && onErrorSupplier && isAdmin &&
                    !widget.isSelf)
                  Row(
                    children: [
                      const Text(
                        'Failed to fetch suppliers, please try again',
                        style: kProductNameStylePro,
                      ),
                      IconButton(
                        onPressed: () {
                          final supplierBloc =
                              BlocProvider.of<SuppliersBloc>(context);
                          final token =
                              Hive.box('adminInfo').get('token');
                          supplierBloc.add(
                            GetSuppliersEvent(
                              token: token,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.refresh,
                          color: kMainColor,
                        ),
                      ),
                    ],
                  )
                else if (isAdmin && !widget.isSelf)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: kNewMainColor,
                      ),
                    ],
                  ),
                const SizedBox(
                  height: 15,
                ),
                const SizedBox(
                  height: 20,
                ),
                if (!widget.isSelf)
                  SwitchListTile(
                      value: isActive,
                      title: const Text(
                        'Activate Admin',
                        style: kProductNameStylePro,
                      ),
                      activeColor: kNewMainColor,
                      onChanged: (bool value) {
                        setState(() {
                          isActive = value;
                        });
                        Provider.of<AdminProvider>(context, listen: false)
                            .updateActive(value);
                      })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PermissionTab extends StatefulWidget {
  final AdminModel adminModel;
  const PermissionTab({required this.adminModel, Key? key}) : super(key: key);

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
      //isLoading = false,
      isDeleteCustomer = false,
      isDeleteEmployee = false,
      isManageDue = false,
      isEditCustomer = false;
  @override
  void initState() {
    // TODO: implement initState
    isAdmin = widget.adminModel.isAdmin;
    isInventory = widget.adminModel.isInventory;
    isMakeAdmin = widget.adminModel.isMakeAdmin;
    isMakeCustomer = widget.adminModel.isMakeCustomer;
    isProduct = widget.adminModel.isProducts;
    isTransaction = widget.adminModel.isTransactions;
    isManageDue = widget.adminModel.isManageDue;
    isDeleteEmployee = widget.adminModel.isDeleteEmployee;
    isDeleteCustomer = widget.adminModel.isDeleteCustomer;
    isEditCustomer = widget.adminModel.isEditCustomer;
    super.initState();
  }

  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Container(
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
                      isEditCustomer = status;
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
                title: const Text(
                  'Create Customers',
                  style: kProductNameStyle,
                ),
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
                title: const Text(
                  'Edit Customers',
                  style: kProductNameStyle,
                ),
                trailing: Switch(
                  activeColor: kMainColor,
                  value: isEditCustomer,
                  onChanged: isAdmin == true
                      ? null
                      : (status) {
                          setState(() {
                            isEditCustomer = status;
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
                  onChanged: isAdmin
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
            child: Consumer<AdminProvider>(builder: (context, admin, any) {
              return InkWell(
                onTap: () async {
                  final adminBloc = BlocProvider.of<AdminBloc>(context);
                  final jWTToken = Hive.box('adminInfo').get('token');
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
                    'adminId': widget.adminModel.adminId,
                    'name': admin.name,
                    'email': admin.email,
                    'active': admin.active,
                  };
                  admin.updateAdminInfo(info);
                  if (widget.adminModel.email != admin.email) {
                    showAuthDialog(context);
                  } else {
                    snackBar(
                      text: 'Updating your information please wait....',
                      context: context,
                      duration: 600,
                      color: kNewMainColor,
                    );
                    adminBloc.add(
                      UpdateAdminEvent(
                        token: jWTToken,
                        adminId: info['adminId'],
                        adminModel: AdminModel.fromJson(info),
                      ),
                    );
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
              );
            }),
          )
        ],
      ),
    );
  }
}
