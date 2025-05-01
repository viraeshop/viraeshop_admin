import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart' hide QuerySnapshot;
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
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

  static Future<void> deleteEmployee(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  static Future<void> supplierPayment(String invoiceId, data) async {
    await _firestore.collection('transaction').doc(invoiceId).set(data);
  }

  static Future<DocumentSnapshot> getSupplierPayment(String invoiceId) async {
    return _firestore.collection('transaction').doc(invoiceId).get();
  }

  static Future deleteCustomerRequest(String docId) async {
    await _firestore.collection('new_customers').doc(docId).delete();
  }

  static Future<void> updateUser(String userId, data) async {
    await _firestore.collection('customers').doc(userId).update(data);
  }

  static Future<bool> isUserExist(String mobile) async {
    final user = await _firestore
        .collection('customers')
        .where('mobile', isEqualTo: mobile)
        .get();
    // if uer is not empty then user already registered else he's not
    return user.docs.isNotEmpty;
  }

  // static Future<Map<String, dynamic>> uploadImageFromNative(
  //     {required File file,
  //       required String fileName,
  //       required String folder}) async {
  //   try {
  //     final StorageUploadFileResult result = await Amplify.Storage.uploadFile(
  //       localFile: file,
  //       key: '$folder/$fileName',
  //       onProgress: (progress) {
  //         safePrint('Fraction completed: ${progress.getFractionCompleted()}');
  //       },
  //       options: UploadFileOptions(
  //           accessLevel: StorageAccessLevel.guest
  //       ), path: null,
  //     );
  //     safePrint('Successfully uploaded file: ${result.key}');
  //     Map<String, dynamic> image = {
  //       'url': 'https://ik.imagekit.io/vira1212/${result.key}',
  //       'key': '$folder/$fileName',
  //     };
  //     return image;
  //   } on StorageException catch (e) {
  //     safePrint('Error uploading file: $e');
  //     throw StorageException(e.message);
  //   }
  // }

  static Future<Map<String, dynamic>> uploadImageFromNative(
      {required PlatformFile file,
      required String folder}) async {
    Map<String, dynamic> image = {};
    try {
      final result = await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromPath(file.path!, name: file.name),
        path: StoragePath.fromString(
          'public/$folder/${file.name}',
        ),
        onProgress: (progress) {
          safePrint('Fraction completed: ${progress.fractionCompleted}');
        },
      ).result;
      safePrint('Successfully uploaded file: ${result.uploadedItem.path}');
      image = {
        'url': 'https://ik.imagekit.io/vira1212/$folder/${file.name}',
        'key': '$folder/${file.name}',
      };
    } on StorageException catch (e) {
      safePrint('Error uploading file: $e');
      //throw StorageException(e.message);
    }
    return image;
  }

  static Future<void> saveAdminInfo(String userId, data) async {
    await _firestore.collection('users').doc(userId).set(data);
  }

  static Future<void> updateAdmin(info, String adminId) async {
    await _firestore.collection('users').doc(adminId).update(info);
  }

  static Future deleteImage({required String key}) async {
    try {
      final result = await Amplify.Storage.remove(
        path: StoragePath.fromString('public/$key'),
      ).result;
      safePrint('Removed file: ${result.removedItem.path}');
    } on StorageException catch (e) {
      safePrint('Error deleting file: $e');
    }
  }

  static Future<String>? deleteProductImages({required List images}) async {
    String message = 'Deleted successfully';
    if (images.isNotEmpty) {
      for (var element in images) {
        try {
          await deleteImage(key: element['imageKey']);
        } on FirebaseException catch (e) {
          if (kDebugMode) {
            print(e.message);
          }
          message = e.message!;
          throw Exception(e.message);
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

  // static Future<void> updateProducts(List cartItems,
  //     [bool isReturn = false]) async {
  //   for (var element in cartItems) {
  //     if (element is Cart) {
  //       if (element.isInventory!) {
  //         await updateProductInventory(
  //             element.productId, element.quantity, isReturn);
  //       }
  //     } else {
  //       if (element['isInventory']) {
  //         await updateProductInventory(
  //             element['productId'], element['quantity'], isReturn);
  //       }
  //     }
  //   }
  // }

  static Future<void> updateWallet(String userId, data) async {
    await _firestore.collection('customers').doc(userId).update(data);
  }
}
