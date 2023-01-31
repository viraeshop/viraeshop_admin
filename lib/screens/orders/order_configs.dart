import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:viraeshop_api/models/orders/orders.dart';

class OrderConfigs extends ChangeNotifier {
  String deliverStats = 'Pending', payStats = 'Due', orderStats = 'pending';
  List<Orders> orders = [];
  bool isLoading = false;
  void updateOrders(List<Orders> order) {
    orders = order;
    notifyListeners();
  }
  void updateDeliveryStats(String newItems) {
    deliverStats = newItems;
    notifyListeners();
  }
  void updatePayStats(String stats) {
    payStats = stats;
    notifyListeners();
  }
  void updateOrderStats(String stats) {
    orderStats = stats;
    notifyListeners();
  }
  void updateLoading (bool update){
    isLoading = update;
    notifyListeners();
  }
   updateNewOrders(){
    DocumentReference documentReference =
      FirebaseFirestore.instance.collection('notifications').doc('newOrders');
  return FirebaseFirestore.instance.runTransaction((transaction) async {
    // Get the document
    DocumentSnapshot snapshot = await transaction.get(documentReference);

    if (!snapshot.exists) {
      throw Exception("not found!");
    }
    var data = snapshot.get('totalOrders');
    var newTotal = data - 1;
    // Perform an update on the document
    transaction.update(documentReference, {'totalOrders': newTotal});
    // Return the new count
    return newTotal;
  });
  }
}
