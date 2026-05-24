import 'package:flutter/foundation.dart';
import 'package:viraeshop_api/models/admin/admins.dart';
import 'package:viraeshop_api/models/items/items.dart';

enum Values {
  deliveryFee,
  advance,
  due,
  discount,
}

enum OrderStages { order, processing, receiving, delivery, admin, emergency, awaitingCustomer }

enum EditingOperation { all, supplyAdmins }

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
      quantity = 0,
      totalAmount = 0,
      total = 0;

  bool isDiscountManuallyEdited = false;
  void onChangeQuantity(bool value, int index) {
    isChangeQuantity[index] = value;
    notifyListeners();
  }

  void updateItemAvailability(bool availability, int index) {
    // Validate index bounds
    if (index < 0 || index >= orderProducts.length) {
      return;
    }

    // Update the specific product's availability
    orderProducts[index].availability = availability;

    // Recalculate all totals from scratch to ensure accuracy
    _recalculateTotals();

    notifyListeners();
  }

// Alternative: Recalculate totals from scratch (more reliable)
  void updateItemAvailabilityWithRecalculation(bool availability, int index) {
    // Validate index bounds
    if (index < 0 || index >= orderProducts.length) {
      return;
    }

    // Update the specific product's availability
    orderProducts[index].availability = availability;

    // Recalculate all totals from scratch
    _recalculateTotals();

    notifyListeners();
  }

  void _recalculateTotals() {
    num itemTotalOriginal = 0;
    num totalDiscountAmount = 0;
    quantity = 0;

    for (var product in orderProducts) {
      if (product.availability == true) {
        itemTotalOriginal += product.editableOriginalPrice;
        totalDiscountAmount += product.editableDiscount;
        quantity += product.editableQuantity;
      }
    }

    if (!isDiscountManuallyEdited) {
      discount = totalDiscountAmount;
    }

    // 1. Base amount (Original Price total)
    num finalTotalAmount = itemTotalOriginal; 
    
    // 2. Sub-total (Original - Discount) -> This is the selling price total
    num currentSubTotal = finalTotalAmount - discount;
    
    // 3. Grand Total (Sub-total + Delivery Fee)
    num finalGrandTotal = currentSubTotal + deliveryFee;
    
    // 4. Due amount (Grand Total - Advance)
    num finalDue = finalGrandTotal - advance;

    // Sync back to Provider variables
    this.totalAmount = finalGrandTotal; // TotalAmount is the Payable Grand Total
    this.subTotal = currentSubTotal;    // SubTotal is Original - Discount
    this.total = finalTotalAmount;      // Total is Original Price
    this.due = finalDue;
  }

  void recalculateTotals() {
    _recalculateTotals();
    notifyListeners();
  }

  void updateProcessingStatus(String status, int index,
      {bool clearCustomerDecisionDeadline = false}) {
    orderProducts[index].processingStatus = status;
    if (clearCustomerDecisionDeadline) {
      orderProducts[index].customerDecisionDeadline = null;
    }
    notifyListeners();
  }

  void updateReceiveStatus(String status, int index) {
    orderProducts[index].receiveStatus = status;
    notifyListeners();
  }

  void updateOrderInfo(String key, dynamic value) {
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
    _recalculateTotals();
    notifyListeners();
  }

  void updateEditableProductsFields(
      int index, EditingOperation op, Map<String, dynamic> data) {
    if (op == EditingOperation.all) {
      orderProducts[index].editableQuantity = data['quantity'];
      orderProducts[index].editableProductPrice = data['discountedPrice'];
      orderProducts[index].editableOriginalPrice = data['originalPrice'];
      orderProducts[index].editableDiscount = data['discount'];
    } else if (op == EditingOperation.supplyAdmins) {
      orderProducts[index].supplyAdmins = data['supplyAdmins'];
    }
    notifyListeners();
  }

  void resetValues() {
    orderProducts.clear();
    total = 0;
    deliveryFee = 0;
    subTotal = 0;
    discount = 0;
    advance = 0;
    due = 0;
    isDiscountManuallyEdited = false;
    notifyListeners();
  }

  void deleteProduct(int index) {
    orderProducts.removeAt(index);
    notifyListeners();
  }

  void updateOrderValues({
    num? advance,
    num? discount,
    num? deliveryFee,
    num? subTotal,
    num? total,
    num? due,
  }) {
    if (total != null) this.total = total;
    if (deliveryFee != null) this.deliveryFee = deliveryFee;
    if (subTotal != null) this.subTotal = subTotal;
    if (discount != null) {
      this.discount = discount;
      if (this.discount != 0) {
        isDiscountManuallyEdited = true;
      }
    }
    if (advance != null) this.advance = advance;
    if (due != null) this.due = due;

    notifyListeners();
  }

  void updateValue(
      {required Values updatingValue, required Map<String, dynamic> values}) {
    if (updatingValue == Values.deliveryFee) {
      deliveryFee = values['deliveryFee'] ?? deliveryFee;
    } else if (updatingValue == Values.advance) {
      advance = values['advance'] ?? advance;
    } else if (updatingValue == Values.discount) {
      discount = values['discount'] ?? discount;
      isDiscountManuallyEdited = true;
    }

    _recalculateTotals();

    orderInfo['deliveryFee'] = deliveryFee;
    orderInfo['discount'] = discount;
    orderInfo['advance'] = advance;
    orderInfo['total'] = total;     // Original Price
    orderInfo['subTotal'] = subTotal; // Selling Price (Original - Discount)
    orderInfo['price'] = subTotal;    // Also used as Selling Price
    orderInfo['due'] = due;
    orderInfo['payable'] = totalAmount; // Grand Total

    notifyListeners();
  }

  void updateOrderStage(OrderStages stage) {
    currentStage = stage;
    notifyListeners();
  }

  void updateFilterInfo(Map<String, dynamic> filterInfo) {
    this.filterInfo = filterInfo;
    notifyListeners();
  }

  void batchUpdateSupplierItems(int supplierId,
      {String? adminId,
      AdminModel? adminModel,
      int? estimatedTime,
      String? processingStatus,
      DateTime? delayedAt,
      DateTime? startedAt}) {
    for (var product in orderProducts) {
      if (product.supplierId == supplierId) {
        if (adminId != null) product.adminId = adminId;
        if (adminModel != null) product.adminModel = adminModel;
        if (estimatedTime != null) product.estimatedTime = estimatedTime;
        if (processingStatus != null)
          product.processingStatus = processingStatus;
        if (startedAt != null) product.startedAt = startedAt;
        if (delayedAt != null) product.delayedAt = delayedAt;
      }
    }
    notifyListeners();
  }

  void batchUpdateItemsByIds(List<dynamic> ids,
      {String? processingStatus,
      int? estimatedTime,
      DateTime? delayedAt,
      DateTime? startedAt,
      DateTime? customerDecisionDeadline,
      bool clearCustomerDecisionDeadline = false}) {
    final stringIds = ids.map((e) => e.toString()).toList();
    for (var product in orderProducts) {
      if (stringIds.contains(product.id.toString())) {
        if (processingStatus != null)
          product.processingStatus = processingStatus;
        if (startedAt != null) product.startedAt = startedAt;
        if (delayedAt != null) product.delayedAt = delayedAt;
        if (estimatedTime != null) product.estimatedTime = estimatedTime;
        if (clearCustomerDecisionDeadline) {
          product.customerDecisionDeadline = null;
        } else if (customerDecisionDeadline != null) {
          product.customerDecisionDeadline = customerDecisionDeadline;
        }
      }
    }
    notifyListeners();
  }
}
