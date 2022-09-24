import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class GeneralCrud {
  final _firestore = FirebaseFirestore.instance;
  // Getting products
  getProducts() {
    return _firestore
        .collection('products')
        .doc('items')
        .collection('products')
        .get();
  }

  Future<QuerySnapshot> getCategoryProducts(String categoryName) async {
    late QuerySnapshot result;
    try {
      result = await _firestore
          .collection('products')
          .doc('items')
          .collection('products')
          .where('category', isEqualTo: categoryName)
          .get();
    } on Exception catch (e) {
      print(e);
    }
    return result;
  }

  getAgentProducts() {
    return _firestore
        .collection('products')
        .doc('items')
        .collection('products')
        .where('product_for', isEqualTo: 'agent')
        .get();
  }

  getArchitectProducts() {
    return _firestore
        .collection('products')
        .doc('items')
        .collection('products')
        .where('product_for', isEqualTo: 'architect')
        .snapshots();
  }

  getGeneralProducts() {
    return _firestore
        .collection('products')
        .doc('items')
        .collection('products')
        .where('product_for', isEqualTo: 'general')
        .snapshots();
  }

  /// get list of chat users
  Future<QuerySnapshot> getChatList() {
    return _firestore.collection('messages').get();
  }

  Future initiateChat(String docId, Map<String, dynamic> data) {
    return _firestore.collection('messages').doc(docId).set(data);
  }

  /// get chat messages
  Stream<QuerySnapshot> getChatMessages(String userId) {
    return _firestore
        .collection('messages')
        .doc(userId)
        .collection('messages')
        .orderBy('date', descending: true)
        .snapshots();
  }

//
  Stream<QuerySnapshot> getCustomers(String role) {
    return _firestore.collection('customers').where('role', isEqualTo: role).snapshots();
  }
  Future<QuerySnapshot> getUsers(String collection) {
    return _firestore.collection(collection).get();
  }

// Archi
  getArchitects() {
    return _firestore.collection('architect').snapshots();
  }

// requests
  getSignups() {
    return _firestore
        .collection('users_registrations')
        .where('verification_status', isEqualTo: 'not-verified')
        .get();
  }

  // Get Users
  Future<bool> getUser(String email, collection) async {
    bool? exist;
    await _firestore
        .collection(collection)
        .where('email', isEqualTo: email)
        .get()
        .then(
      (value) {
        if (value.docs.isNotEmpty) {
          exist = true;
        } else {
          exist = false;
        }
      },
    );
    return exist!;
  }

// Get Users
  getAgent(email) async {
    var user = {};
    await _firestore
        .collection('customers')
        // .collection('users_registrations')
        .where('email', isEqualTo: email)
        .get()
        .then((value) {
      // value.docs;
      for (var snapshot in value.docs) {
        Map<String, dynamic> data = snapshot.data();
        user = data;
        // print(data.toString());
      }
    });
    print(jsonEncode(user));
    return user;
  }

  /// Accept customer
  // Future<void> makeCustomer(String data, ) async {
  //   await _firestore.collection('returns').doc().set(data);
  // }

  getExpense() async {
    var user = {};
    await _firestore
        .collection('expenses')
        // .collection('users_registrations')
        // .where('email', isEqualTo: email)
        .get()
        .then((value) {
      // value.docs;
      for (var snapshot in value.docs) {
        Map<String, dynamic> data = snapshot.data();
        user = data;
        // print(data.toString());
      }
    });
    print(jsonEncode(user));
    return user;
  }

// Getting order
  Future<QuerySnapshot> getOrder() {
    return _firestore.collection('order').get();
  }

  // get all orders
  Stream <DocumentSnapshot> getNotifyInfo(String docId) {
    return _firestore.collection('notifications')
    .doc(docId)
    .snapshots();
  }

  // Return
  Stream<QuerySnapshot> getReturn() {
    return FirebaseFirestore.instance.collection('returns').snapshots();
  }

// make returns
  Future<void> makeReturn(data) async {
    await _firestore.collection('returns').add(data);
  }

// orders
  makeOrder(orderData, String docId) async {
    await FirebaseFirestore.instance
        .collection('order')
        .doc(docId)
        .set(orderData)
        // .then((value) => print('Product Added ' + value.toString()))
        .catchError((e) {
      print('error $e');
      return false;
    }).then((value) {
      return true;
    });
    return true;
  }

// customer order history
  Future<QuerySnapshot> getCustomerOrder(String customerId) {
    return _firestore
        .collection('order')
        .where('customer_info.customer_id', isEqualTo: customerId)
        .get();
  }

  // Get Image Url
  imagetUrl(imageName) async {
    firebase_storage.Reference imref =
        firebase_storage.FirebaseStorage.instance.ref().child(imageName);
    String url = await imref.getDownloadURL();
    return url;
  }

  Future<QuerySnapshot> getCategories() {
    return _firestore
        .collection('products')
        .doc('category')
        .collection('categories')
        .get();
  }

  Future<void> updateInvoice(String docId, transInfo) async {
    await _firestore.collection('transaction').doc(docId).update(transInfo);
  }

  Future<DocumentSnapshot> searchInvoice(String docId) {
    return _firestore.collection('transaction').doc(docId).get();
  }

  makeExpense(info) async {
    await FirebaseFirestore.instance.collection('product_expense').add(info);
  }

  Future<QuerySnapshot> getCustomerList(String role) {
    if(role == 'All'){
      return FirebaseFirestore.instance.collection('customers').get();
    }else{
      return FirebaseFirestore.instance.collection('customers').where('role', isEqualTo: role).get();
    }
  }

  Future<QuerySnapshot> getTransaction() {
    return FirebaseFirestore.instance.collection('transaction').get();
  }

  Future<QuerySnapshot> getExpenses() {
    return FirebaseFirestore.instance.collection('expenses').get();
  }
}
