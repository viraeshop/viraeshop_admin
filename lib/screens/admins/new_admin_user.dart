import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_bloc/admin/admin_bloc.dart';
import 'package:viraeshop_bloc/admin/admin_event.dart';
import 'package:viraeshop_bloc/admin/admin_state.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/admins/permission_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewAdmin extends StatelessWidget {
  NewAdmin({Key? key}) : super(key: key);
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _iDController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final labelStyle = const TextStyle(
    color: kSubMainColor,
    fontSize: 15.0,
    fontFamily: 'Montserrat',
    letterSpacing: 1.3,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            final adminBloc = BlocProvider.of<AdminBloc>(context);
            if(adminBloc.state is! FetchedAdminsState){
              final jWTToken = Hive.box('adminInfo').get('token');
              adminBloc.add(GetAdminsEvent(token: jWTToken));
            }
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close,
            color: kSubMainColor,
          ),
        ),
        title: const Text(
          'New User',
          style: kProductNameStylePro,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
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
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _nameController,
                        validator: (value){
                          if (value == null || value.isEmpty) {
                              return 'Please enter the name';
                            }
                            return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: kSubMainColor,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: kMainColor,
                            ),
                          ),
                          labelText: "Full Name",
                          labelStyle: labelStyle,
                        ),
                      ),
                      const SizedBox(
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
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: kSubMainColor,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: kMainColor,
                            ),
                          ),
                          labelText: "Email",
                          labelStyle: labelStyle,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
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
                          //'adminId': _iDController.text,
                        }).whenComplete(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PermissionPage(),
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
                      child: const Center(
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
      ),
    );
  }
}
