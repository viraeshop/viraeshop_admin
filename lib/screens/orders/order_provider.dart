import 'package:flutter/foundation.dart';

enum Values {
  deliveryFee,
  advance,
  due,
  discount,
}

enum OrderStages {
  order,
  processing,
  receiving,
  delivery
}

class OrderProvider extends ChangeNotifier {
  bool onStatusFilter = false;
  String currentOrderStatus = 'all';
  List<bool> isChangeQuantity = [];
  List orderProducts = [];
  Map<String, dynamic> orderInfo = {};
  OrderStages currentStage = OrderStages.order;
  num due = 0,
      advance = 0,
      discount = 0,
      deliveryFee = 0,
      subTotal = 0,
      total = 0;
  void onChangeQuantity(bool value, int index) {
    isChangeQuantity[index] = value;
    notifyListeners();
  }

  void updateOrderInfo(String key,dynamic value){
    orderInfo[key] = value;
    notifyListeners();
  }

  void onUpdateProducts(List<Map<String, dynamic>> value) {
    orderProducts = value;
    notifyListeners();
  }

  void deleteProduct (int index){
    orderProducts.removeAt(index);
    notifyListeners();
  }

  void updateOrderValues({
     required num due, advance, discount, deliveryFee, subTotal, total}) {
    this.total = total;
    this.deliveryFee = deliveryFee;
    this.subTotal = subTotal;
    this.discount = discount;
    this.advance =  advance;
    this.due = due;
    notifyListeners();
  }

  void updateValue({required Values updatingValue,required Map<String, dynamic> values}){
    if(updatingValue == Values.deliveryFee){
      deliveryFee = values['deliveryFee'];
      total = values['total'];
      subTotal = values['subTotal'];
    } else if (updatingValue == Values.advance){
      advance = values['advance'];
      due = values['due'];
    } else if (updatingValue ==  Values.discount){

    }
    notifyListeners();
  }

  void updateOrderStage(OrderStages stage){
    currentStage = stage;
    notifyListeners();
  }

  void updateOnStatusFilter (bool value, status){
    onStatusFilter = value;
    currentOrderStatus = status;
    notifyListeners();
  }
}
