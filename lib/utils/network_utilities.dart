import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:pdf/widgets.dart';

class NetworkUtility {
  static final FirebaseFirestore _firestore =  FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static firebase_storage.SettableMetadata metadata =
  firebase_storage.SettableMetadata(
    contentType: 'image/jpeg',
  );
  static Future<QuerySnapshot> getCustomerTransactionInvoices (String customerId){
    return _firestore.collection('transaction').where('user_info.name', isEqualTo: customerId).get();
  }
  static Future<void> updateCustomerDue (String invoiceId, data) {
    _firestore.collection('transaction').doc(invoiceId).update(data);
    throw Exception('Error updating due in invoice');
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
  static Future<UserCredential> registerUserEmail (String email, password) async{
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }
  static Future<void> saveUserInfo (String userId, data) async{
    await _firestore.collection('customers').doc(userId).set(data);
  }
  static Future<void> supplierPayment (String businessName, data) async{
    await _firestore.collection('supplier_pay').doc(businessName).set(data);
  }
  static Future<DocumentSnapshot> getSupplierPayment (String businessName) async{
    return _firestore.collection('supplier_pay').doc(businessName).get();
  }
  static Future<void> updateUser (String userId, data) async{
    await _firestore.collection('customers').doc(userId).update(data);
  }
  static Future<String> uploadImageFromNative (File file, String fileName, folder) async{
    await _storage.ref().child('$folder/$fileName').putFile(file, metadata);
    Reference fileRef = _storage.ref('$folder/$fileName');
    String fileUrl = await fileRef.getDownloadURL();
    return fileUrl;
  }
}