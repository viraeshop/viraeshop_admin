import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/decoration.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/signup_page.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({Key? key}) : super(key: key);

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _passwordController = TextEditingController();  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) => Container(
            width: constraints.maxWidth > 600
                ? MediaQuery.of(context).size.width * 0.40
                : null,
            height: MediaQuery.of(context).size.height * 0.75,
            margin: const EdgeInsets.all(16),
            decoration: kBoxDecoration,
            child: Column(
              // shrinkWrap: true,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Verify Administrator', style: kProductNameStylePro,),
                const SizedBox(height: 10.0,),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: myField(
                    hint: 'Secret Code',
                    input_type: 'password',
                    myController: _passwordController,
                    obscure: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: InkWell(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 58,
                      decoration: BoxDecoration(
                          color:
                              kSelectedTileColor, //Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(15)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Verify",
                            style:
                                TextStyle(fontSize: 20, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      String code = 'pAYdfxgi';
                      if (code == _passwordController.text) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupPage(),
                          ),
                        );
                      } else {
                        showDialogBox(
                            buildContext: context,
                            msg: 'Code entered Incorrectly');
                      }
                                        },
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
