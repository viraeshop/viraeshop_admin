import 'package:flutter/foundation.dart';

class GeneralProvider extends ChangeNotifier {
  List advertSelected = [];
  List suppliers = [];
  List suppliersBackup= [];
  List<bool> addedToCart = List.generate(10, (index) => false);
  bool isStarted = false;
  bool isEditUser = false;
  void onUserEdit (bool value){
    isEditUser = value;
    notifyListeners();
  }
  void addAdvert(String value) {
    advertSelected.add(value);
    notifyListeners();
  }
  void removeAdvert(String value) {
    advertSelected.remove(value);
    notifyListeners();
  }
  void updateAdList(List value){
    advertSelected = value;
    notifyListeners();
  }
  void animationTrigger(bool value, int index){
    addedToCart[index] = value;
    notifyListeners();
  }
  void animationTracker (bool value){
    isStarted = value;
    notifyListeners();
  }
  void updateAnimationTrigger (List<bool> value){
    addedToCart = value;
    notifyListeners();
  }
  void getSuppliers (List suppliers){
    this.suppliers = suppliers;
    suppliersBackup = suppliers;
    notifyListeners();
  }
  void updateSuppliersList (List suppliers){
    this.suppliers = suppliers;
    notifyListeners();
  }
}
