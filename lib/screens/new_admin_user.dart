import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/permission_page.dart';

class NewAdmin extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  NewAdmin();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _iDController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      color: kSubMainColor,
      fontSize: 15.0,
      fontFamily: 'Montserrat',
      letterSpacing: 1.3,
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.close,
            color: kSubMainColor,
          ),
        ),
        title: Text(
          'New User',
          style: kProductNameStylePro,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Container(
          height: MediaQuery.of(context).size.height,
          // width: MediaQuery.of(context).size.width * 0.45,
          child: Form(
            key: _formKey,
            child: Stack(children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _nameController,
                      validator: (value){
                        if (value == null || value.isEmpty) {
                            return 'Please enter the name';
                          }
                          return null;
                      },
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
                        labelStyle: labelStyle,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _emailController,
                      validator: (value){
                        if (value == null || value.isEmpty) {
                            return 'Please enter the email address';
                          }
                          return null;
                      },
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
                        labelStyle: labelStyle,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _iDController,
                      validator: (value){
                        if (value == null || value.isEmpty) {
                            return 'Please enter the admin id';
                          }
                          return null;
                      },
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
                          labelStyle: labelStyle),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      Hive.box('newAdmin').putAll({
                        'email': _emailController.text,
                        'name': _nameController.text,
                        'adminId': _iDController.text,
                      }).whenComplete(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PermissionPage(),
                          ),
                        );
                      });
                    }
                  },
                  child: Container(
                    height: 50.0,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: kBackgroundColor,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: kMainColor),
                    ),
                    child: Center(
                      child: Text(
                        'Next',
                        style: kButtonTextStyle,
                      ),
                    ),
                  ),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
