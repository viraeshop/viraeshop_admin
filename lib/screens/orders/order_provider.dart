import 'package:flutter/foundation.dart';

class OrderProvider extends ChangeNotifier{
  List<bool> isChangeQuantity = [];
  List orderProducts = [];
  void onChangeQuantity (bool value, int index){
    isChangeQuantity[index] = value;
    notifyListeners();
  }
  void onUpdateProducts (List value, List<bool> booleans){
    orderProducts = value;
    isChangeQuantity = booleans;
    notifyListeners();
  }
}