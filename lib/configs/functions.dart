import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/configs/boxes.dart';
import 'package:viraeshop_admin/screens/advert/ads_provider.dart';
import 'package:viraeshop_api/utils/utils.dart';

Future<void> updateProductInventory(String docPath, num productQuantity, [bool isReturn = false]) {
  DocumentReference documentReference = FirebaseFirestore.instance
      .collection('products')
      .doc('items')
      .collection('products')
      .doc(docPath);
  return FirebaseFirestore.instance.runTransaction((transaction) async {
    // Get the document
    DocumentSnapshot snapshot = await transaction.get(documentReference);

    if (!snapshot.exists) {
      throw Exception("not found!");
    }
    var totalProductQuantity = snapshot.get('quantity');
    var newTotal = 0;
    if(isReturn){
      newTotal = totalProductQuantity + productQuantity;
    }else{
      newTotal = totalProductQuantity - productQuantity;
    }
    // Perform an update on the document
    transaction.update(documentReference, {'quantity': newTotal});
    // Return the new count
  });
}
initSearch({required String value, required BuildContext context,required List temps, reset, update}) {
  List products = Hive.box(productsBox).get(productsKey);
  List tempStore = temps;
    if (value.length == 0) {
      Provider.of<AdsProvider>(context, listen: false).updateProductList(tempStore);
    }
    final filteredList = products.where((element) {
      final String nameLower = element['name'].toLowerCase();
      final idLower = element['productId'].toLowerCase();
      final valueLower = value.toLowerCase();
      return nameLower.contains(valueLower) || idLower.contains(valueLower);
    }).toList();
    Provider.of<AdsProvider>(context, listen: false).updateProductList(filteredList);
  }

List searchEngine({required String value,required String key,required List temps, bool isNested = false, String key2 = '', String key3 = ''}) {
  String field = '';
  String field2 = '';
  final filteredList = temps.where((element) {
    if(isNested){
      field = element[key][key2]?.toLowerCase() ?? '';
      field2 = element[key][key3]?.toLowerCase() ?? '';
    }else{
      if(key == 'invoiceNo'){
        field = element[key].toString();
      }else{
        field = element[key]?.toLowerCase() ?? '';
      }
      field2 = element[key2]?.toLowerCase() ?? '';
    }
    final valueLower = value.toLowerCase();
    return field.contains(valueLower) || field2.contains(valueLower);
  }).toList();
  return filteredList;
}

List dateFilter (List data, DateTime begin, DateTime end){
  return data.where((element) {
    Timestamp timestamp = dateFromJson(element['createdAt']);
    DateTime date = timestamp.toDate();
    begin = DateTime(begin.year, begin.month, begin.day);
    end = DateTime(end.year, end.month, end.day);
    DateTime dateFormatted = DateTime(date.year, date.month, date.day);
    return ((begin.isAfter(dateFormatted) ||
        begin.isAtSameMomentAs(dateFormatted)) &&
        (end.isBefore(dateFormatted) || end.isAtSameMomentAs(dateFormatted)));
  }).toList();
}

int generateInvoiceNumber (){
  const int max = 2500;
  const int min = 2000;
  Random rnd = Random();
  return (min + rnd.nextInt(max - min));
}

int getItemIndex (List items, Map item){
  for(int i = 0; i<items.length; i++){
    if(items[i]['productId'] == item['productId']){
      return i;
    }
  }
  return -1;
}
