import 'package:flutter/foundation.dart';

class AdminProvider extends ChangeNotifier{
  String email = '';
  String name = '';
  String oldEmail = '';
  bool active = true;
  Map<String, dynamic> adminInfo = {};

  void updateEmail (String email){
    this.email = email;
    notifyListeners();
  }

  void updateActive (bool value){
    active = value;
    notifyListeners();
  }
  void saveExistingEmail (String email){
    oldEmail = email;
    notifyListeners();
  }

  void updateName (String name){
    this.name = name;
    notifyListeners();
  }

  void updateAdminInfo (Map<String, dynamic> adminInfo){
    this.adminInfo = adminInfo;
    notifyListeners();
  }
}