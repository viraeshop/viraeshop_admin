import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdsProvider extends ChangeNotifier {
  List adCards = [];
  List products = [];
  List addedToCart = [];
  Map<String, Map<String, TextEditingController>> controllers = {};
  String currentCatg = 'All';
  String drawerWidget = 'Tab Widget';
  bool isSearch = false;
  bool isAnimationStarted = false;
  void updateAddedToCart(List<bool> values){
    addedToCart = values;
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

  void updateCatg(String value) {
    currentCatg = value;
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
    if (index == -1) {
      adCards.add(newEntry);
      notifyListeners();
    }
  }

  void deleteAdCard(String adId) {
    int index = adIndex(adId);
    print('Item index $index');
    adCards.removeAt(index);
    notifyListeners();
  }

  void updateAdCard(
    String adId,
    String title1,
    title2,
    title3,
  ) {
    int index = adIndex(adId);
    print('Item index $index');
    adCards[index]['title1'] = title1;
    adCards[index]['title2'] = title2;
    adCards[index]['title3'] = title3;
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

  void addController(String key, Map<String, TextEditingController> value) {
    if (!controllers.containsKey(key)) {
      controllers[key] = value;
      notifyListeners();
    }
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
