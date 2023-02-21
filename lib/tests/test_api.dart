import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop/admin/admin_bloc.dart';
import 'package:viraeshop/admin/admin_event.dart';
import 'package:viraeshop/admin/admin_state.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_api/models/admin/admins.dart';
import 'package:viraeshop_api/apiCalls/category.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TestApi extends StatefulWidget {
  const TestApi({Key? key}) : super(key: key);

  @override
  State<TestApi> createState() => _TestApiState();
}

class _TestApiState extends State<TestApi> {
  // bool start = false;
  final jWTToken = Hive.box('adminInfo').get('token');
  final auth = FirebaseAuth.instance;
  @override
  void initState() {
    // TODO: implement initState
    final adminBloc = BlocProvider.of<AdminBloc>(context);
    adminBloc.add(GetAdminsEvent(token: jWTToken));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: kBackgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text(
                    'Add Category',
                    style: kProductNameStyle,
                  ),
                  onPressed: () async{
                    // snackBar(text: 'Updating', context: context, duration: 100,);
                     try{
                    //   final user = await auth.signInWithEmailAndPassword(email: 'omar@gmail.com', password: '2337271a');
                    //   final update = await user.user?.updateEmail('viraeshop@gmail.com');
                    //   final passwordUpdate = user.user?.updatePassword("233727");
                    //   toast(context: context, title: 'Updated successfully');
                       final jWTToken = Hive.box('adminInfo').get('token');
                       CategoryCalls().addCategory(
                         {
                           'category': 'Api testing',
                           'image': '',
                           'imageKey': '',
                         },
                        jWTToken);
                    } catch (e){
                      print(e);
                    }
                  },
                ),
                ElevatedButton(
                  child: const Text(
                    'Get',
                    style: kProductNameStyle,
                  ),
                  onPressed: () {},
                ),
                const SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                  child: const Text(
                    'Create',
                    style: kProductNameStyle,
                  ),
                  onPressed: () async {},
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        );
  }
}
