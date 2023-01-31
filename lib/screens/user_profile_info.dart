import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/form_field.dart';
import 'package:viraeshop_admin/screens/update_user.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
//
// class UserProfileInfo extends StatelessWidget {
//   final dynamic userInfo;
//   final String docId;
//   const UserProfileInfo({required this.userInfo, required this.docId, Key? key}): super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return UpdateUser(userInfo: userInfo, userId: docId);
//   }
// }

class DesktopProfilePage extends StatefulWidget {
  final dynamic userInfo;
  final String docId;
  DesktopProfilePage({required this.userInfo, required this.docId});

  @override
  _DesktopProfilePageState createState() => _DesktopProfilePageState();
}

class _DesktopProfilePageState extends State<DesktopProfilePage> {
  static List<String> userType = [
    'general',
    'agents',
    'architect',
  ];
  List<DropdownMenuItem> userTypesDropdown = List.generate(
    userType.length,
    (index) => DropdownMenuItem(
      value: userType[index],
      child: Text(
        userType[index],
        style: kCategoryNameStyle,
      ),
    ),
  );
  String? selectedUserType;
  final formGlobalKey = GlobalKey<FormState>();
  bool isLoading = false;
  AdminCrud adminCrud = AdminCrud();

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController =
        TextEditingController(text: widget.userInfo['name']);
    TextEditingController mobileController =
        TextEditingController(text: widget.userInfo['mobile']);
    TextEditingController addressController =
        TextEditingController(text: widget.userInfo['address']);
    TextEditingController emailController =
        TextEditingController(text: widget.userInfo['email']);
    TextEditingController workPhoneController =
        TextEditingController(text: widget.userInfo['work_phone']);
    TextEditingController iDController =
        TextEditingController(text: widget.userInfo['id']);
    TextEditingController passwordController =
        TextEditingController(text: widget.userInfo['password']);
    TextEditingController notesController =
        TextEditingController(text: widget.userInfo['notes']);
    return Scaffold(
      backgroundColor: kScaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: kSelectedTileColor),
        elevation: 0.0,
        backgroundColor: kBackgroundColor,
        title: const Text(
          'User profile',
          style: kAppBarTitleTextStyle,
        ),
        centerTitle: false,
        titleTextStyle: kProductNameStylePro,
        actions: [
          IconButton(
            onPressed: () {
             showDialog(context: context, builder: (context){
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
                      await FirebaseFirestore.instance
                          .collection(widget.userInfo['role'])
                          .doc(widget.docId)
                          .delete();
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
             },);
            },
            icon: const Icon(
              Icons.delete,
            ),
            color: kSubMainColor,
            iconSize: 20.0,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(40.0),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: kBackgroundColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    // margin: EdgeInsets.all(10.0),
                    height: MediaQuery.of(context).size.height * 0.40,
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 15.0, top: 15.0),
                          child: Text(
                            'User Info',
                            style: kCategoryNameStyle,
                          ),
                        ),
                        const SizedBox(
                          width: double.infinity,
                          child: Divider(
                            color: kScaffoldBackgroundColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Column(
                            children: [
                              HeadingTextField(
                                onMaxLine: false,
                                controller: nameController,
                                heading: 'Name: ',
                                keyboardType: TextInputType.name,
                              ),
                              HeadingTextField(
                                onMaxLine: false,
                                controller: mobileController,
                                heading: 'Mobile #: ',
                                keyboardType: TextInputType.number,
                              ),
                              HeadingTextField(
                                onMaxLine: false,
                                controller: addressController,
                                heading: 'Address: ',
                                keyboardType: TextInputType.streetAddress,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: kBackgroundColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    // margin: EdgeInsets.all(10.0),
                    height: MediaQuery.of(context).size.height * 0.7,
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 15.0, top: 15.0),
                          child: Text(
                            'Details',
                            style: kCategoryNameStyle,
                          ),
                        ),
                        const SizedBox(
                          width: double.infinity,
                          child: Divider(
                            color: kScaffoldBackgroundColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Email:',
                                    style: kProductNameStylePro,
                                  ),
                                  Container(
                                    height: 40.0,
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    margin: const EdgeInsets.all(10.0),
                                    child: Center(
                                      child: TextFormField(
                                        controller: emailController,
                                        cursorColor: kMainColor,
                                        style: kProductNameStylePro,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.done,
                                        maxLines: 1,
                                        // validator: (email) {
                                        //   if (isEmailValid(email!))
                                        //     return null;
                                        //   else
                                        //     return 'Enter a valid email address';
                                        // },
                                        decoration: const InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: kMainColor),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: kMainColor),
                                          ),
                                          focusColor: kMainColor,
                                          errorBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.red),
                                          ),
                                        ),
                                        // onFieldSubmitted: (value) {
                                        //   setState(() => {isEditable = false, title = value});
                                        // }
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              HeadingTextField(
                                onMaxLine: false,
                                controller: workPhoneController,
                                heading: 'Work phone: ',
                                keyboardType: TextInputType.number,
                              ),
                              HeadingTextField(
                                onMaxLine: false,
                                controller: iDController,
                                heading: 'ID #: ',
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Password:',
                                    style: kProductNameStylePro,
                                  ),
                                  Container(
                                    height: 60.0,
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    margin: const EdgeInsets.all(10.0),
                                    child: Center(
                                      child: TextFormField(
                                        controller: passwordController,
                                        cursorColor: kMainColor,
                                        style: kProductNameStylePro,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.done,
                                        maxLines: 1,
                                        maxLength: 6,
                                        // validator: (password) {
                                        //   if (password!.length < 6) {
                                        //     return 'Enter a valid password';
                                        //   }
                                        //   return null;
                                        // },
                                        decoration: const InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: kMainColor),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: kMainColor),
                                          ),
                                          focusColor: kMainColor,
                                          errorBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.red),
                                          ),
                                        ),
                                        // onFieldSubmitted: (value) {
                                        //   setState(() => {isEditable = false, title = value});
                                        // }
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'User Type: ',
                                    style: kProductPriceStylePro,
                                  ),
                                  Center(
                                    child: Container(
                                      height: 46.0,
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      margin: const EdgeInsets.all(10.0),
                                      child: DropdownButtonFormField(
                                        items: userTypesDropdown,
                                        value: selectedUserType,
                                        decoration: const InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: kMainColor),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: kMainColor),
                                          ),
                                          focusColor: kMainColor,
                                        ),
                                        onChanged: (dynamic value) {
                                          setState(() {
                                            selectedUserType = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 30.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  profilePic(
                      imageUrl: widget.userInfo['image'], context: context),
                  const SizedBox(height: 10.0),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: MediaQuery.of(context).size.width * 0.25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: kBackgroundColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 15.0, left: 15.0),
                          child: Text(
                            'Notes',
                            style: kCategoryNameStyle,
                          ),
                        ),
                        const SizedBox(
                          width: double.infinity,
                          child: Divider(
                            color: kScaffoldBackgroundColor,
                          ),
                        ),
                        // SizedBox(
                        //   height: 10.0,
                        // ),
                        Container(
                          margin: const EdgeInsets.all(10.0),
                          decoration: const BoxDecoration(
                              // border: Border.all(
                              //   color: kScaffoldBackgroundColor,
                              // ),
                              ),
                          height: MediaQuery.of(context).size.height * 0.20,
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: Center(
                            child: TextFormField(
                              controller: notesController,
                              cursorColor: kMainColor,
                              style: kProductNameStylePro,
                              textInputAction: TextInputAction.done,
                              maxLines: 10,
                              decoration: const InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: kMainColor),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: kMainColor),
                                ),
                                focusColor: kMainColor,
                              ),
                              // onFieldSubmitted: (value) {
                              //   setState(() => {isEditable = false, title = value});
                              // }
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  widget.userInfo['role'] == 'agents'
                      ? walletWidget()
                      : const SizedBox(),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        child: Container(
                          // padding: EdgeInsets.all(15),
                          // margin: EdgeInsets.all(15.0),
                          width: MediaQuery.of(context).size.width * 0.25,
                          height: 40.0,
                          decoration: BoxDecoration(
                              color:
                                  kMainColor, //Theme.of(context).accentColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Center(
                            child: Text(
                              "update",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                        onTap: () {
                          bool isNotEmpty() {
                            if (nameController.text.isNotEmpty &&
                                mobileController.text.isNotEmpty &&
                                addressController.text.isNotEmpty &&
                                workPhoneController.text.isNotEmpty &&
                                iDController.text.isNotEmpty &&
                                passwordController.text.isNotEmpty &&
                                emailController.text.isNotEmpty &&
                                selectedUserType != null) {
                              return true;
                            } else {
                              return false;
                            }
                          }

                          bool check = isNotEmpty();
                          print('check: $check');
                          if (check == true) {
                            setState(() {
                              isLoading = true;
                            });
                            Map<String, dynamic> fields = {
                              'name': nameController.text,
                              'mobile': mobileController.text,
                              'address': addressController.text,
                              'work_phone': workPhoneController.text,
                              'email': emailController.text,
                              'notes': notesController.text,
                            };
                            GeneralCrud generalCrud = GeneralCrud();
                            generalCrud
                                .getUser(
                                    emailController.text, selectedUserType)
                                .then((value) {
                              if (value) {
                                setState(() {
                                  isLoading = false;
                                });
                                showDialogBox(
                                  buildContext: context,
                                  msg: 'User Already Exist',
                                );
                              } else {
                                adminCrud.addCustomer('',fields).then((added) {
                                  if (added) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    showDialogBox(
                                      buildContext: context,
                                      msg: 'User Created',
                                    );
                                  } else {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    showDialogBox(
                                      buildContext: context,
                                      msg: 'An error occured please try again',
                                    );
                                  }
                                });
                              }
                            });
                          } else {
                            setState(() {
                              isLoading = false;
                            });
                            showDialogBox(
                              buildContext: context,
                              msg: 'Fields can\'t be empty!',
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget profilePic({required String imageUrl, required BuildContext context}) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: kBackgroundColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 15.0, top: 15.0),
                    child: Text(
                      'Profile Picture',
                      style: kCategoryNameStyle,
                    ),
                  ),
                  const SizedBox(
                    width: double.infinity,
                    child: Divider(
                      color: kScaffoldBackgroundColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.all(10.0),
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.25,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: DecorationImage(
                    image: NetworkImage(imageUrl), fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(3.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> walletDialog({
    required BuildContext buildContext,
  }) async {
    TextEditingController controller = TextEditingController();
    AdminCrud adminCrud = AdminCrud();
    String indicatorText = 'Update';
    return showDialog<void>(
      context: buildContext,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text('Update Wallet'),
          titleTextStyle: kProductNameStyle,
          // ignore: dead_code
          content: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: ListBody(
              children: <Widget>[
                Container(
                  height: 40.0,
                  // width: MediaQuery.of(context).size.width * 0.4,
                  margin: const EdgeInsets.all(15.0),
                  child: Center(
                    child: TextFormField(
                      controller: controller,
                      cursorColor: kMainColor,
                      style: kProductNameStylePro,
                      textInputAction: TextInputAction.done,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kMainColor),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: kMainColor),
                        ),
                        focusColor: kMainColor,
                      ),
                      // onFieldSubmitted: (value) {
                      //   setState(() => {isEditable = false, title = value});
                      // }
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            InkWell(
              onTap: () {
                // Provider.of<Configs>(context, listen: false)
                //     .updateText('Upating...');
                double amount = double.parse(controller.text);
                adminCrud
                    .wallet(widget.docId, amount)
                    .then((value) {
                  // Provider.of<Configs>(context, listen: false)
                  //     .updateText('Done');
                  Navigator.pop(context);
                  //print("Follower count updated to $value");
                }).catchError(
                  (error) {
                    Provider.of<Configs>(context, listen: false)
                        .updateText('Try Again');
                    // Navigator.pop(context);
                    print("Failed to update user followers: $error");
                  },
                );
              },
              child: Container(
                width: 100.0,
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                  color: kMainColor,
                ),
                child: Center(
                  child: Consumer<Configs>(
                    builder: (context, configs, childs) => Text(
                      configs.indicatorText,
                      style: const TextStyle(
                        fontSize: 15.0,
                        color: kBackgroundColor,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget walletWidget() {
    return Container(
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      // margin: EdgeInsets.all(10.0),
      height: MediaQuery.of(context).size.height * 0.4,
      width: MediaQuery.of(context).size.width * 0.25,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 15.0, top: 15.0),
            child: Text(
              'Wallet',
              style: kCategoryNameStyle,
            ),
          ),
          const SizedBox(
            width: double.infinity,
            child: Divider(
              color: kScaffoldBackgroundColor,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(15.0),
            child: Center(
                child: Column(
              children: [
                const Text(
                  'Current Account Balance',
                  style: kProductNameStyle,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('customers')
                        .doc(widget.docId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(
                          color: kMainColor,
                        );
                      }
                      if (snapshot.hasData) {
                        final data = snapshot.data!.get('wallet');
                        print(data);
                        return Text(
                          data.toString(),
                          style: const TextStyle(
                            color: kSubMainColor,
                            fontSize: 30.0,
                            fontFamily: 'Montserrat',
                            letterSpacing: 1.3,
                          ),
                        );
                      }
                      return const Text(
                        '0.0',
                        style: TextStyle(
                          color: kSubMainColor,
                          fontSize: 30.0,
                          fontFamily: 'Montserrat',
                          letterSpacing: 1.3,
                        ),
                      );
                    }),
                const SizedBox(
                  height: 20.0,
                ),
                InkWell(
                  onTap: () {
                    walletDialog(buildContext: context);
                  },
                  child: Container(
                    // padding: EdgeInsets.all(15),
                    // margin: EdgeInsets.all(15.0),
                    width: double.infinity,
                    height: 30.0,
                    decoration: BoxDecoration(
                      color: kMainColor, //Theme.of(context).accentColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Center(
                      child: Text(
                        "Update Balance",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }
}
