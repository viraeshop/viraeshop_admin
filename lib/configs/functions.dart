import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/configs/baxes.dart';
import 'package:viraeshop_admin/screens/advert/ads_provider.dart';

Future<void> updateProductInventory(String docPath, num productQuantity) {
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
    var newTotal = totalProductQuantity - productQuantity;
    // Perform an update on the document
    transaction.update(documentReference, {'quantity': newTotal});
    // Return the new count
  });
}

Future deleteImage(String ref) async{
  try {
   FirebaseStorage _storage = FirebaseStorage.instance;
   await _storage.ref(ref).delete();
  } on FirebaseException catch (e) {
    print('Delete error: $e');
  }
}
initSearch({required String value,required BuildContext context,required List temps, reset, update}) {
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

