import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:viraeshop_admin/configs/functions.dart';
import 'package:viraeshop_admin/reusable_widgets/hive/cart_model.dart';

class NetworkUtility {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static firebase_storage.SettableMetadata metadata =
      firebase_storage.SettableMetadata(
    contentType: 'image/jpeg',
  );
  static Future<QuerySnapshot> getCustomerTransactionInvoices(List customerId) {
    return _firestore
        .collection('transaction')
        .where('user_info.search_keywords', arrayContains: customerId[0])
        .get();
  }

  static Future<DocumentSnapshot> getCustomerTransactionInvoicesByID(
      String invoiceId) {
    return _firestore.collection('transaction').doc(invoiceId).get();
  }

  static Future<void> deleteInvoice(String invoiceId) async {
    await _firestore.collection('transaction').doc(invoiceId).delete();
  }

  static Future<void> updateCustomerDue(String invoiceId, data) async {
    await _firestore.collection('transaction').doc(invoiceId).update(data);
  }

  static Future<void> deleteCustomer(String userId) async {
    await _firestore.collection('customers').doc(userId).delete();
  }

  static Future<void> verifyEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static Future<UserCredential> registerUserEmail(
      String email, password) async {
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  static Future<void> saveUserInfo(String userId, data) async {
    await _firestore.collection('customers').doc(userId).set(data);
  }

  static Future<void> deleteEmployee (String userId) async{
    await _firestore.collection('users').doc(userId).delete();
  }

  static Future<void> supplierPayment(String businessName, data) async {
    await _firestore.collection('supplier_pay').doc(businessName).set(data);
  }

  static Future<DocumentSnapshot> getSupplierPayment(
      String businessName) async {
    return _firestore.collection('supplier_pay').doc(businessName).get();
  }

  static Future<void> updateUser(String userId, data) async {
    await _firestore.collection('customers').doc(userId).update(data);
  }

  static Future<String> uploadImageFromNative(
      File file, String fileName, folder) async {
    await _storage.ref().child('$folder/$fileName').putFile(file, metadata);
    Reference fileRef = _storage.ref('$folder/$fileName');
    String fileUrl = await fileRef.getDownloadURL();
    return fileUrl;
  }

  static Future<void> saveAdminInfo(String userId, data) async {
    await _firestore.collection('users').doc(userId).set(data);
  }

  static Future<void> updateAdmin(info, String adminId) async {
    await _firestore.collection('users').doc(adminId).update(info);
  }

  static Future deleteImage(String ref) async {
    await _storage.refFromURL(ref).delete();
  }

  static Future<String>? deleteProductImages(List image) async {
    String message = 'Deleted successfully';
    if (image.isNotEmpty) {
      for (var element in image) {
        try {
          await deleteImage(element);
        } on FirebaseException catch (e) {
          if (kDebugMode) {
            print(e.message);
          }
          message = e.message!;
        }
      }
    } else {
      message = 'No image';
    }
    return message;
  }

  static Future<void> deleteProduct(String productId) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc('items')
        .collection('products')
        .doc(productId)
        .delete();
  }
  static Future<void> makeTransaction(String docId, transInfo) async {
    await _firestore.collection('transaction').doc(docId).set(transInfo);
  }
  static Future<void> updateProducts(List<Cart> cartItems) async {
    for (var element in cartItems) {
      if(element.isInventory!){
        await updateProductInventory(element.productId, element.quantity);
      }
    }
  }
  static Future<void> updateWallet (String userId, data) async{
    await _firestore.collection('customers').doc(userId).update(data);
  }
}
