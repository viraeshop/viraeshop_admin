import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/non_inventory_product.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';

class Shops extends StatefulWidget {
  const Shops({Key? key}) : super(key: key);

  @override
  _ShopsState createState() => _ShopsState();
}

class _ShopsState extends State<Shops> {
  List<TextEditingController> controllers =
      List.generate(7, (index) => TextEditingController());
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(
        color: kMainColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.chevron_left),
            color: kSubMainColor,
            iconSize: 20.0,
          ),
          title: const Text(
            'Create shop',
            style: kAppBarTitleTextStyle,
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20.0,
              ),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 60.0,
                    backgroundColor: kNewTextColor,
                  ),
                  const SizedBox(width: 20.0),
                  Expanded(
                    child: Column(
                      children: [
                        textField(
                            controller: controllers[0],
                            prefixIcon: const Icon(
                              Icons.person,
                              color: kNewTextColor,
                              size: 20,
                            ),
                            hintText: 'Name of supplier'),
                        const SizedBox(
                          height: 10.0,
                        ),
                        textField(
                            controller: controllers[1],
                            prefixIcon: const Icon(
                              Icons.business,
                              color: kNewTextColor,
                              size: 20,
                            ),
                            hintText: 'Business name',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              textField(
                  controller: controllers[2],
                  prefixIcon: const Icon(
                    Icons.phone_android,
                    color: kNewTextColor,
                    size: 20,
                  ),
                  hintText: 'Phone'),
              const SizedBox(
                height: 10.0,
              ),
              textField(
                  controller: controllers[3],
                  prefixIcon: const Icon(
                    Icons.email,
                    color: kNewTextColor,
                    size: 20,
                  ),
                  hintText: 'Email'),
              const SizedBox(
                height: 10.0,
              ),
              textField(
                  controller: controllers[4],
                 prefixIcon: const Icon(
                    Icons.room,
                    color: kNewTextColor,
                    size: 20,
                  ),
                  hintText: 'Address'),
              const SizedBox(
                height: 20.0,
              ),
              sendButton(
               title: 'Create',
               onTap:  () {
                  if (controllers[0].text != null) {
                    setState(() {
                        isLoading = false;
                      });
                    AdminCrud().addShop(controllers[0].text, {
                      'name': controllers[0].text,
                      'business_name': controllers[1].text,
                      'email': controllers[3].text,
                      'mobile': controllers[2].text,
                      'address': controllers[4].text,
                    }).then((value) {
                      setState(() {
                        isLoading = false;
                      });
                    }).catchError((error) {
                      setState(() {
                        isLoading = false;
                      });
                    });
                  } else {
                    showMyDialog('Fields can\'t be empty', context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget sendButton({required String title, void Function()? onTap, double width = double.infinity, height = 50.0, Color color = kNewTextColor}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: color,
      ),
      child: Center(
        child: Text(
          title,
          style: kTableHeadingStyle,
        ),
      ),
    ),
  );
}
