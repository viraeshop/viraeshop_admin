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

enum EditingOperation {
  all,
  supplyAdmins
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

  void updateItemAvailability (bool availability, int index){
    orderProducts[index].availability = availability;
    if(availability) {
      subTotal += orderProducts[index].editableProductPrice;
      total += orderProducts[index].editableOriginalPrice;
      discount += orderProducts[index].editableDiscount;
    }
    notifyListeners();
  }

  void updateProcessingStatus (String status, int index){
    orderProducts[index].processingStatus = status;
    notifyListeners();
  }

  void updateOrderInfo(String key,dynamic value){
    orderInfo[key] = value;
    notifyListeners();
  }

  void onUpdateProducts(List<Items> value) {
    orderProducts = value.toList();
    for (var e in orderProducts) {
      e.editableQuantity = e.quantity;
      e.editableProductPrice = e.productPrice;
      e.editableOriginalPrice = e.originalPrice;
      e.editableDiscount = e.discount;
    }
    notifyListeners();
  }

  void updateEditableProductsFields (int index, EditingOperation op, Map<String, dynamic> data) {
    if(op == EditingOperation.all){
      orderProducts[index].editableQuantity = data['quantity'];
      orderProducts[index].editableProductPrice = data['discountedPrice'];
      orderProducts[index].editableOriginalPrice = data['originalPrice'];
      orderProducts[index].editableDiscount = data['discount'];
    } else if (op == EditingOperation.supplyAdmins){
      orderProducts[index].supplyAdmins = data['supplyAdmins'];
    }
    notifyListeners();
  }

  void resetValues (){
    orderProducts.clear();
    total = 0;
    deliveryFee = 0;
    subTotal = 0;
    discount = 0;
    advance =  0;
    due = 0;
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
