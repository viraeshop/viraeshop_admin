import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:viraeshop_admin/settings/authentication.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:viraeshop_admin/settings/general_crud.dart';

class AdminCrud {
  // Contains all admin operations like adding products, staffs, agents, etc

  // Add new Products
  addProduct(productData, String category) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc('items')
        .collection('products')
        .doc(category)
        .set(productData)
        // .then((value) => print('Product Added ' + value.toString()))
        .catchError((e) {
      return false;
    }).then((value) {
      return true;
    });
    return true;
  }

  Future<void> createTransaction(String docId, data) async {
    await FirebaseFirestore.instance
        .collection('transaction')
        .doc(docId)
        .set(data);
  }

  Future<DocumentSnapshot> getSingleOrder(String orderId) async {
    return FirebaseFirestore.instance.collection('order').doc(orderId).get();
  }

  updateProduct(productData, String productName) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc('items')
        .collection('products')
        .doc(productName)
        .update(productData)
        // .then((value) => print('Product Added ' + value.toString()))
        .catchError((e) {
      return false;
    }).then((value) {
      return true;
    });
    return true;
  }

  Future<void> addAdmin(String docId, info) async {
    await FirebaseFirestore.instance.collection('users').doc(docId).set(info);
  }

  Future<void> addShop(String docId, info) async {
    await FirebaseFirestore.instance.collection('shops').doc(docId).set(info);
  }

  Future<QuerySnapshot> getShop() {
    return FirebaseFirestore.instance.collection('shops').get();
  }

  Future<void> updateNonInventory(String docId, data) async {
    await FirebaseFirestore.instance
        .collection('transaction')
        .doc(docId)
        .update(data);
  }

  updateAdmin(info, String adminId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(adminId)
        .update(info);
  }

  addCategory(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc('category')
        .collection('categories')
        .add(data)
        .catchError((e) {
      return false;
    }).then((value) {
      return true;
    });
    return true;
  }

  Future<void> updateCategory(Map<String, dynamic> data, String docId) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc('category')
        .collection('categories')
        .doc(docId)
        .update(data);
  }

  Stream<QuerySnapshot> getCategories() {
    return FirebaseFirestore.instance
        .collection('products')
        .doc('category')
        .collection('categories')
        .snapshots();
  }

  Future<void> deleteCategory(String docId) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc('category')
        .collection('categories')
        .doc(docId)
        .delete();
  }

// Update Order
  updateOrder(orderId, orderData) async {
    await FirebaseFirestore.instance
        .collection('order')
        .doc(orderId)
        .update(orderData)
        // .then((value) => print('Product Added ' + value.toString()))
        .catchError((e) {
      return false;
    }).then((value) {
      return true;
    });
    return true;
  }

// Add New Users
  Future addCustomer(String docId, cusData) async {
    await FirebaseFirestore.instance
        .collection('customers')
        .doc(docId)
        .set(cusData);
  }

  Future deleteCustomerRequest(String docId) async {
    await FirebaseFirestore.instance
        .collection('new_customers')
        .doc(docId)
        .delete();
  }

// Update
  updateCustomer({cid, cusData, collection = 'agents'}) async {
    FirebaseFirestore.instance
        .collection('$collection')
        .doc(cid)
        .update(cusData)
        .catchError((e) {
      return false;
    }).then((value) {
      return true;
    });
    return true;
  }

// update wallet
  Future<void> wallet(String documentId, var balance) async{
        await FirebaseFirestore.instance.collection('customers').doc(documentId).update({
          'wallet': balance,
        });
  }

  updateWallet({required String documentId, var balance, bool isDeduct = true}) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('customers').doc(documentId);
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot snapshot = await transaction.get(documentReference);

      if (!snapshot.exists) {
        throw Exception("User does not exist!");
      }
      var data = snapshot.get('wallet');
      num newBalance = 0.0;
      if(isDeduct){
        newBalance = data - balance;
      }else{
        newBalance = data + balance;
      }
      // Perform an update on the document
      transaction.update(documentReference, {'wallet': newBalance});
      // Return the new count
      return newBalance;
    });
  }

// Update
  // updateWallet(String docId, amount) async {
  //   GeneralCrud generalCrud = GeneralCrud();
  //   await generalCrud.getAgent('${agentId['email']}').then((userval) async {
  //     // print(userval['wallet'].toString());
  //     var new_wallet = userval['wallet'] + amount;
  //     // print(new_wallet);
  //     await FirebaseFirestore.instance
  //         .collection('agents')
  //         .doc(agentId['id'])
  //         .update({'wallet': new_wallet}).catchError((e) {
  //       return false;
  //     }).then((value) {
  //       return true;
  //     });
  //   });
  //   //

  //   return true;
  // }

// Update return
  updateReturn(returnId, returnData) async {
    await FirebaseFirestore.instance
        .collection('return')
        .doc(returnId)
        .update(returnData)
        .catchError((e) {
      return false;
    }).then((value) {
      return true;
    });
  }

  deleteAllProducts() async {
    var collection = FirebaseFirestore.instance.collection('products');
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  deleteAllReturns() async {
    var collection = FirebaseFirestore.instance.collection('return');
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  deleteAllExpenses() async {
    var collection = FirebaseFirestore.instance.collection('expenses');
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  // Add expenses
  addExpenses(expenseData) async {
    await FirebaseFirestore.instance.collection('expenses').add(expenseData)
        // .then((value) => print('Product Added ' + value.toString()))
        .catchError((e) {
      return false;
    }).then((value) {
      return true;
    });
    return true;
  }

  uploadImage({filePath, imageName}) async {
    await FirebaseStorage.instance.ref().child(imageName).putFile(filePath);
    // .then((v) => v);
    firebase_storage.Reference imref =
        firebase_storage.FirebaseStorage.instance.ref().child(imageName);
    String imageUrl = await imref.getDownloadURL();
    return imageUrl;
    // return url;
  }

  firebase_storage.SettableMetadata metadata =
      firebase_storage.SettableMetadata(
    contentType: 'image/jpeg',
  );
  Future<String> uploadWebImage(Uint8List fileBytes, String fileName) async {
    await FirebaseStorage.instance
        .ref('images/$fileName')
        .putData(fileBytes, metadata);
    firebase_storage.Reference imref =
        firebase_storage.FirebaseStorage.instance.ref('images/$fileName');
    String imageUrl = await imref.getDownloadURL();
    print(imageUrl);
    return imageUrl;
  }
}
