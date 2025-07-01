import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdsProvider extends ChangeNotifier {
  List adCards = [];
  List products = [];
  List addedToCart = [];
  List<Map<String, dynamic>> subCategories = [];
  String currentCatg = 'All';
  int? categoryId;
  String subCategory = '';
  String dropdownValue = 'general';
  bool hasSubCatg = false;
  String drawerWidget = 'Tab Widget';
  bool isSearch = false;
  bool isAnimationStarted = false;
  void updateAddedToCart(List<bool> values){
    addedToCart = values;
    notifyListeners();
  }
  void updateHasSubCatg(bool value){
    hasSubCatg = value;
    notifyListeners();
  }
  void updateSubCategories(List<Map<String, dynamic>> values){
    subCategories = values;
    notifyListeners();
  }

  void updateCurrentSubCategory(String value){
    subCategory = value;
    notifyListeners();
  }

  void updateDropdownValue(String value){
    dropdownValue = value;
    notifyListeners();
  }

  void animationTrigger(bool value, int index){
    addedToCart[index] = value;
    notifyListeners();
  }
  void animationTracker (bool value){
    isAnimationStarted = value;
    notifyListeners();
  }
  void switchSearch (bool value){
    isSearch = value;
    notifyListeners();
  }

  void updateCatg(String value, {int? id}) {
    if (kDebugMode) {
      print('Category updated to: $value with id: $id');
    }
    currentCatg = value;
    categoryId = id;
    notifyListeners();
  }
  
  void updateProductList (List newValue){
    products = newValue;
    notifyListeners();
  }

  void updateDrawerWidget(String value) {
    drawerWidget = value;
    notifyListeners();
  }

  void addAdCard(String adId, Map newEntry) {
    int index = adIndex(adId);
    print(index);
    if (index == -1) {
      adCards.add(newEntry);
      notifyListeners();
    }
  }

  void clearAdCards() {
    adCards.clear();
    notifyListeners();
  }

  void deleteAdCard(String adId) {
    int index = adIndex(adId);
    adCards.removeAt(index);
    notifyListeners();
  }

  void updateAdCard(
    String adId,
    String searchTerm,
  ) {
    int index = adIndex(adId);
    adCards[index]['searchTerm'] = searchTerm;
    notifyListeners();
  }

  void saveImages({required String adId, image, Uint8List? imagesBytes, String? imagePath,required String imageKey}) {
    int index = adIndex(adId);
    if (kDebugMode) {
      print('Item index $index');
    }
    adCards[index]['image'] = image;
    adCards[index]['imageKey'] = imageKey;
    adCards[index]['imageBytes'] = imagesBytes;
    adCards[index]['imagePath'] = imagePath;
    notifyListeners();
  }

  void onEdit(String adId, bool value) {
    int index = adIndex(adId);
    print('Item index $index');
    adCards[index]['isEdit'] = value;
    notifyListeners();
  }

  int adIndex(String adId) {
    int position = 0;
    while (position < adCards.length) {
      if (adCards[position]['adId'] == adId) {
        return position;
      }
      position += 1;
    }
    return -1;
  }
}
