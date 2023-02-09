import 'package:flutter/foundation.dart';

class CustomerProvider extends ChangeNotifier{
  num wallet = 0;

  void updateWallet (num value, [bool add = false]){
    if(add){
      wallet += value;
    }else{
      wallet = value;
    }
    notifyListeners();
  }
}