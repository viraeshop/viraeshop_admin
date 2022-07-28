import 'package:cloud_firestore/cloud_firestore.dart';

class NetworkUtility {
  static final FirebaseFirestore _firestore =  FirebaseFirestore.instance;
  static Future<QuerySnapshot> getCustomerTransactionInvoices (String customerId){
    return _firestore.collection('transaction').where('user_info.name', isEqualTo: customerId).get();
  }
  static Future<void> updateCustomerDue (String invoiceId, data) {
    _firestore.collection('transaction').doc(invoiceId).update(data);
    throw Exception('Error updating due in invoice');
  }
}