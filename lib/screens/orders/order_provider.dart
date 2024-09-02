import 'package:flutter/foundation.dart';
import 'package:viraeshop_api/models/items/items.dart';

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
  delivery,
  admin
}

class OrderProvider extends ChangeNotifier {
  List<bool> isChangeQuantity = [];
  List<Items> orderProducts = [];
  Map<String, dynamic> orderInfo = {};
  Map<String, dynamic> filterInfo = {};
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

  void onUpdateProducts(List<Items> value) {
    orderProducts = value;
    notifyListeners();
  }

  void deleteProduct (int index){
    orderProducts.removeAt(index);
    notifyListeners();
  }

  void updateOrderValues({
     required num advance, discount, deliveryFee, subTotal, total, due}) {
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
      discount = values['discount'];
      total = values['total'];
      subTotal = values['subTotal'];
      //due = values['due'];
    }
    notifyListeners();
  }

  void updateOrderStage(OrderStages stage){
    currentStage = stage;
    notifyListeners();
  }

  void updateFilterInfo (Map<String, dynamic> filterInfo){
    this.filterInfo = filterInfo;
    notifyListeners();
  }
}
