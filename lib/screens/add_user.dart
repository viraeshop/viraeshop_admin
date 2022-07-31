import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/form_field.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';

class CreateUser extends StatelessWidget {
  const CreateUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600) {
        return UserRegistrationDesktop();
      } else {
        return NewUserMobile();
      }
    });
  }
}

class NewUserMobile extends StatefulWidget {
  const NewUserMobile({Key? key}) : super(key: key);

  @override
  _NewUserMobileState createState() => _NewUserMobileState();
}

class _NewUserMobileState extends State<NewUserMobile> {
  var default_role = 'General';
  var selected_role = '';
  List _myList = ['general', 'agents', 'architect'];
  bool showFields = true;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _workPhoneController = TextEditingController();
  TextEditingController _iDController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _notesController = TextEditingController();
  Uint8List? images;
  File? _imageFile;
  String? profileImage;
  var currdate = DateTime.now();
  AdminCrud adminCrud = AdminCrud();
  GeneralCrud generalCrud = GeneralCrud();
  String _uniqueCode = randomAlphaNumeric(10);
  bool isLoading = false;
  DecorationImage _imageBG() {
    if (kIsWeb) {
      return images == null
          ? DecorationImage(
              image: AssetImage('assets/default.jpg'), fit: BoxFit.cover)
          : DecorationImage(image: MemoryImage(images!), fit: BoxFit.cover);
    } else {
      return _imageFile == null
          ? DecorationImage(
              image: AssetImage('assets/default.jpg'), fit: BoxFit.cover)
          : DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover);
    }
  }

  void getImageWeb() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Uint8List imageBytes = result.files.first.bytes ?? Uint8List(0);
      String? fileName = result.files.first.name;
      adminCrud.uploadWebImage(imageBytes, fileName, '').then((imageUrl) {
        setState(() {
          images = result.files.first.bytes;
          profileImage = imageUrl;
        });
      });
    }
  }

  Future selectImage() async {
    try {
      final image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 50,
          maxHeight: 480,
          maxWidth: 640);
      if (image != null) {
        var fullImage = 'images/product_$_uniqueCode.jpg';
        adminCrud
            .uploadImage(filePath: File(image.path), imageName: fullImage)
            .then((imageUrl) {
          setState(() {
            this._imageFile = File(image.path);
            profileImage = imageUrl;
          });
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        backgroundColor: kspareColor,
        appBar: AppBar(
          iconTheme: IconThemeData(color: kSelectedTileColor),
          elevation: 0.0,
          backgroundColor: kBackgroundColor,
          title: Text(
            'New User',
            style: kAppBarTitleTextStyle,
          ),
          centerTitle: true,
          titleTextStyle: kTextStyle1,
        ),
        body: pageOne(),
      ),
    );
  }

  pageOne() {
    return Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
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
                        SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          width: 150,
                          child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Stack(
                                  children: [
                                    // Align(
                                    //   alignment: Alignment.center,
                                    //   child: Column(
                                    //     crossAxisAlignment:
                                    //         CrossAxisAlignment.start,
                                    //     children: [
                                    //       Padding(
                                    //         padding: EdgeInsets.only(
                                    //             left: 15.0, top: 15.0),
                                    //         child: Text(
                                    //           'Pick Product Image',
                                    //           style: kCategoryNameStyle,
                                    //         ),
                                    //       ),
                                    //       SizedBox(
                                    //         width: double.infinity,
                                    //         child: Divider(
                                    //           color:
                                    //               kScaffoldBackgroundColor,
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        margin: EdgeInsets.all(10.0),
                                        height: 200,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          image: _imageBG(),
                                          borderRadius:
                                              BorderRadius.circular(3.0),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: InkWell(
                                        onTap: () {
                                          if (kIsWeb) {
                                            getImageWeb();
                                          } else {
                                            selectImage();
                                          }
                                        },
                                        child: Icon(Icons.add_a_photo, size: 30),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Second item
                        // Padding(
                        //   padding: const EdgeInsets.all(30.0),
                        //   child: Row(children: [
                        //     MyIcons(icon: Icons.call),
                        //     MyIcons(icon: Icons.sms),
                        //     MyIcons(icon: Icons.email),
                        //     // MyIcons(
                        //     //     icon: Icons.location_city,
                        //     //     onClick: () => print('Hello World'))
                        //   ]),
                        // ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                SizedBox(height: 10),
                                TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: "Full Name",
                                    hintText: "",
                                    // border: OutlineInputBorder(
                                    //     borderRadius:
                                    //         BorderRadius.circular(15))
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextField(
                                  controller: _mobileController,
                                  decoration: InputDecoration(
                                    labelText: "mobile",
                                    hintText: "",
                                    // border: OutlineInputBorder(
                                    //     borderRadius:
                                    //         BorderRadius.circular(15))
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextField(
                                  controller: _addressController,
                                  decoration: InputDecoration(
                                    labelText: "Address",
                                    hintText: "",
                                    // border: OutlineInputBorder(
                                    //     borderRadius:
                                    //         BorderRadius.circular(15))
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Last Part

                        SizedBox(
                          height: 20,
                        ),
                        Card(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  hintText: "",
                                  // border: OutlineInputBorder(
                                  //     borderRadius: BorderRadius.circular(15))
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  hintText: "",
                                  // border: OutlineInputBorder(
                                  //     borderRadius: BorderRadius.circular(15))
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextField(
                                controller: _workPhoneController,
                                decoration: InputDecoration(
                                  labelText: "Work Phone",
                                  hintText: "",
                                  // border: OutlineInputBorder(
                                  //     borderRadius: BorderRadius.circular(15))
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              DropdownButtonFormField(
                                decoration: InputDecoration(
                                    // border: OutlineInputBorder(
                                    //     borderRadius: BorderRadius.circular(15)),
                                    // labelText: "Quantity",
                                    // hintText: "Quantity",
                                    hintStyle:
                                        TextStyle(color: Colors.black87)),
                                hint: Text(
                                    'Select Role'), // Not necessary for Option 1
                                // value: default_role,
                                onChanged: (change_val) {
                                  print(change_val);
                                  setState(() {
                                    selected_role = change_val.toString();
                                    print(selected_role);
                                  });
                                },
                                items: _myList.map((itm) {
                                  return DropdownMenuItem(
                                    child: new Text(itm),
                                    value: itm,
                                  );
                                }).toList(),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextField(
                                controller: _iDController,
                                decoration: InputDecoration(
                                  labelText: "User Id",
                                  hintText: "",
                                  // border: OutlineInputBorder(
                                  //     borderRadius: BorderRadius.circular(15))
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextField(
                                controller: _notesController,
                                decoration: InputDecoration(
                                  labelText: "notes",
                                  hintText: "",
                                  // border: OutlineInputBorder(
                                  //     borderRadius: BorderRadius.circular(15))
                                ),
                              ),
                              SizedBox(height: 10)
                            ],
                          ),
                        )),
                        SizedBox(height: 20),
                        bottomCard(
                          context: context,
                          text: 'Save',
                          onTap: () {
                            bool isNotEmpty() {
                              if (_nameController.text.isNotEmpty &&
                                  _mobileController.text.isNotEmpty &&
                                  _addressController.text.isNotEmpty &&
                                  _workPhoneController.text.isNotEmpty &&
                                  _iDController.text.isNotEmpty &&
                                  _passwordController.text.isNotEmpty &&
                                  _emailController.text.isNotEmpty &&
                                  selected_role != null) {
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
                              if (profileImage != null) {
                                Map<String, dynamic> fields = {
                                  'name': _nameController.text,
                                  'mobile': _mobileController.text,
                                  'address': _addressController.text,
                                  'work_phone': _workPhoneController.text,
                                  'id': _iDController.text,
                                  'password': _passwordController.text,
                                  'email': _emailController.text,
                                  'notes': _notesController.text,
                                  'image': profileImage,
                                  'role': selected_role,
                                };
                                GeneralCrud generalCrud = GeneralCrud();
                                generalCrud
                                    .getUser(
                                        _emailController.text, selected_role)
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
                                          msg:
                                              'An error occured please try again',
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
                                  msg: 'Sorry Profile image is Missing',
                                );
                              }
                              // ignore: dead_code
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
                  )),
              Center(
                child: myLoader(text: 'Loading..', visibility: !showFields),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class UserRegistrationDesktop extends StatefulWidget {
  const UserRegistrationDesktop({Key? key}) : super(key: key);

  @override
  _UserRegistrationDesktopState createState() =>
      _UserRegistrationDesktopState();
}

class _UserRegistrationDesktopState extends State<UserRegistrationDesktop>
    with InputValidationMixin {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _workPhoneController = TextEditingController();
  TextEditingController _iDController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _notesController = TextEditingController();
  Uint8List? images;
  String? profileImage;
  File? _imageFile;
  AdminCrud adminCrud = AdminCrud();
  String _uniqueCode = randomAlphaNumeric(10);
  DecorationImage _imageBG() {
    if (kIsWeb) {
      return images == null
          ? DecorationImage(
              image: AssetImage('assets/default.jpg'), fit: BoxFit.cover)
          : DecorationImage(image: MemoryImage(images!), fit: BoxFit.cover);
    } else {
      return _imageFile == null
          ? DecorationImage(
              image: AssetImage('assets/default.jpg'), fit: BoxFit.cover)
          : DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover);
    }
  }

  static List<String> userType = [
    'general',
    'agents',
    'architect',
  ];
  List<DropdownMenuItem> userTypesDropdown = List.generate(
    userType.length,
    (index) => DropdownMenuItem(
      child: Text(
        userType[index],
        style: kCategoryNameStyle,
      ),
      value: userType[index],
    ),
  );
  String? selectedUserType;
  final formGlobalKey = GlobalKey<FormState>();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      color: kMainColor,
      inAsyncCall: isLoading,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(color: kSelectedTileColor),
          elevation: 0.0,
          backgroundColor: kBackgroundColor,
          title: Text(
            'New User',
            style: kAppBarTitleTextStyle,
          ),
          centerTitle: true,
          titleTextStyle: kTextStyle1,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(40.0),
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
                          Padding(
                            padding: EdgeInsets.only(left: 15.0, top: 15.0),
                            child: Text(
                              'User Info',
                              style: kCategoryNameStyle,
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Divider(
                              color: kScaffoldBackgroundColor,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: Column(
                              children: [
                                HeadingTextField(
                                  onMaxLine: false,
                                  controller: _nameController,
                                  heading: 'Name: ',
                                  keyboardType: TextInputType.name,
                                ),
                                HeadingTextField(
                                  onMaxLine: false,
                                  controller: _mobileController,
                                  heading: 'Mobile #: ',
                                  keyboardType: TextInputType.number,
                                ),
                                HeadingTextField(
                                  onMaxLine: false,
                                  controller: _addressController,
                                  heading: 'Address: ',
                                  keyboardType: TextInputType.streetAddress,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
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
                          Padding(
                            padding: EdgeInsets.only(left: 15.0, top: 15.0),
                            child: Text(
                              'Details',
                              style: kCategoryNameStyle,
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Divider(
                              color: kScaffoldBackgroundColor,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Email:',
                                      style: kProductNameStylePro,
                                    ),
                                    Container(
                                      height: 40.0,
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      margin: EdgeInsets.all(10.0),
                                      child: Center(
                                        child: TextFormField(
                                          controller: _emailController,
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
                                          decoration: InputDecoration(
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
                                  controller: _workPhoneController,
                                  heading: 'Work phone: ',
                                  keyboardType: TextInputType.number,
                                ),
                                HeadingTextField(
                                  onMaxLine: false,
                                  controller: _iDController,
                                  heading: 'ID #: ',
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Password:',
                                      style: kProductNameStylePro,
                                    ),
                                    Container(
                                      height: 60.0,
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      margin: EdgeInsets.all(10.0),
                                      child: Center(
                                        child: TextFormField(
                                          controller: _passwordController,
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
                                          decoration: InputDecoration(
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
                                    Text(
                                      'User Type: ',
                                      style: kProductPriceStylePro,
                                    ),
                                    Center(
                                      child: Container(
                                        height: 46.0,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        margin: EdgeInsets.all(10.0),
                                        child: DropdownButtonFormField(
                                          items: userTypesDropdown,
                                          value: selectedUserType,
                                          decoration: InputDecoration(
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
                SizedBox(
                  width: 30.0,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    imagePickerContainer(context),
                    SizedBox(height: 10.0),
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
                          Padding(
                            padding: EdgeInsets.only(top: 15.0, left: 15.0),
                            child: Text(
                              'Notes',
                              style: kCategoryNameStyle,
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Divider(
                              color: kScaffoldBackgroundColor,
                            ),
                          ),
                          // SizedBox(
                          //   height: 10.0,
                          // ),
                          Container(
                            margin: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                                // border: Border.all(
                                //   color: kScaffoldBackgroundColor,
                                // ),
                                ),
                            height: MediaQuery.of(context).size.height * 0.20,
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: Center(
                              child: TextFormField(
                                controller: _notesController,
                                cursorColor: kMainColor,
                                style: kProductNameStylePro,
                                textInputAction: TextInputAction.done,
                                maxLines: 10,
                                decoration: InputDecoration(
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
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          child: Container(
                            // padding: EdgeInsets.all(15),
                            // margin: EdgeInsets.all(15.0),
                            width: MediaQuery.of(context).size.width * 0.25,
                            height: 30.0,
                            decoration: BoxDecoration(
                                color:
                                    kMainColor, //Theme.of(context).accentColor,
                                borderRadius: BorderRadius.circular(5)),
                            child: Center(
                              child: Text(
                                "Save",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                          ),
                          onTap: () {
                            bool isNotEmpty() {
                              if (_nameController.text.isNotEmpty &&
                                  _mobileController.text.isNotEmpty &&
                                  _addressController.text.isNotEmpty &&
                                  _workPhoneController.text.isNotEmpty &&
                                  _iDController.text.isNotEmpty &&
                                  _passwordController.text.isNotEmpty &&
                                  _emailController.text.isNotEmpty &&
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
                              if (profileImage != null) {
                                Map<String, dynamic> fields = {
                                  'name': _nameController.text,
                                  'mobile': _mobileController.text,
                                  'address': _addressController.text,
                                  'work_phone': _workPhoneController.text,
                                  'id': _iDController.text,
                                  'password': _passwordController.text,
                                  'email': _emailController.text,
                                  'notes': _notesController.text,
                                  'image': profileImage,
                                  'role': selectedUserType,
                                };
                                GeneralCrud generalCrud = GeneralCrud();
                                generalCrud
                                    .getUser(
                                        _emailController.text, selectedUserType)
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
                                          msg:
                                              'An error occured please try again',
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
                                  msg: 'Sorry Profile image is Missing',
                                );
                              }
                              // ignore: dead_code
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
      ),
    );
  }

  Container imagePickerContainer(BuildContext context) {
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
                  Padding(
                    padding: EdgeInsets.only(left: 15.0, top: 15.0),
                    child: Text(
                      'Pick Product Image',
                      style: kCategoryNameStyle,
                    ),
                  ),
                  SizedBox(
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
              margin: EdgeInsets.all(10.0),
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.25,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: _imageBG(),
                borderRadius: BorderRadius.circular(3.0),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: InkWell(
              onTap: () {
                if (kIsWeb) {
                  getImageWeb();
                } else {
                  selectImage();
                }
              },
              child: Icon(Icons.add_a_photo, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Future selectImage() async {
    try {
      final image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 50,
          maxHeight: 480,
          maxWidth: 640);
      if (image != null) {
        var fullImage = 'images/product_$_uniqueCode.jpg';
        adminCrud
            .uploadImage(filePath: File(image.path), imageName: fullImage)
            .then((imageUrl) {
          setState(() {
            this._imageFile = File(image.path);
            profileImage = imageUrl;
          });
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void getImageWeb() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Uint8List imageBytes = result.files.first.bytes ?? Uint8List(0);
      String? fileName = result.files.first.name;
      adminCrud.uploadWebImage(imageBytes, fileName,'').then((imageUrl) {
        setState(() {
          images = result.files.first.bytes;
          profileImage = imageUrl;
        });
      });
    }
  }
}

mixin InputValidationMixin {
  bool isPasswordValid(String password) => password.length == 6;

  bool isEmailValid(String email) {
    var pattern =
        r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }
}
