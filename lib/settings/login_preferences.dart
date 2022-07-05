import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

addlogin(item) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // int counter = (prefs.getInt('counter') ?? 0) + 1;
  // print('Pressed $counter times.');
  await prefs.setString('login', item);
  return true;
}

getlogin() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.get('login');
}

Future removeLogin() async {
  return Hive.box('adminInfo').clear();
}

saveUserType(String type){
   Hive.box('userType').put('userType', type);
}