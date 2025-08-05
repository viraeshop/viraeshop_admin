import 'package:flutter/foundation.dart';
import 'package:viraeshop_admin/screens/products/bulk_edit_product.dart';

class BulkEditProvider with ChangeNotifier {
  List<ProductEntity> products = [];
  List<Map<String, dynamic>> bulkEdit = [];

  void setProducts(List<ProductEntity> value) {
    products = value;
    notifyListeners();
  }

  void updateProduct(List<Map<String, dynamic>> value) {
    for (var element in value) {
      final index = products.indexWhere((e) => e.productId == element['id']);
      final bulkEditIndex =
          bulkEdit.indexWhere((e) => e.containsKey(element['id']));
      if (index != -1) {
        if (element['agentsPrice'] != null) {
          products[index].agentsPrice = element['agentsPrice'];
          bulkEdit[bulkEditIndex][element['id']]['agentsPrice'] =
              element['agentsPrice'];
        }
        if (element['generalPrice'] != null) {
          products[index].generalPrice = element['generalPrice'];
          bulkEdit[bulkEditIndex][element['id']]['generalPrice'] =
              element['generalPrice'];
        }
        if (element['architectPrice'] != null) {
          products[index].architectPrice = element['architectPrice'];
          bulkEdit[bulkEditIndex][element['id']]['architectPrice'] =
              element['architectPrice'];
        }
        if (element['agentsDiscount'] != null) {
          products[index].agentsDiscount = element['agentsDiscount'];
          bulkEdit[bulkEditIndex][element['id']]['agentsDiscount'] =
              element['agentsDiscount'];
        }
        if (element['generalDiscount'] != null) {
          products[index].generalDiscount = element['generalDiscount'];
          bulkEdit[bulkEditIndex][element['id']]['generalDiscount'] =
              element['generalDiscount'];
        }
        if (element['architectDiscount'] != null) {
          products[index].architectDiscount = element['architectDiscount'];
          bulkEdit[bulkEditIndex][element['id']]['architectDiscount'] =
              element['architectDiscount'];
        }
        if (element['cost'] != null) {
          products[index].cost = element['cost'];
          bulkEdit[bulkEditIndex][element['id']]['cost'] = element['cost'];
        }
      }
    }
    notifyListeners();
  }

  void selectProduct(String productId) {
    final index =
        products.indexWhere((element) => element.productId == productId);
    products[index].isSelected = !products[index].isSelected;
    if (products[index].isSelected) {
      bulkEdit.add(
        {
          productId: {
            'agentsPrice': products[index].agentsPrice,
            'generalPrice': products[index].generalPrice,
            'architectPrice': products[index].architectPrice,
            'agentsDiscount': products[index].agentsDiscount,
            'generalDiscount': products[index].generalDiscount,
            'architectDiscount': products[index].architectDiscount,
            'costPrice': products[index].cost,
          },
        },
      );
    } else {
      bulkEdit.removeWhere((element) => element.containsKey(productId));
    }
    notifyListeners();
  }

  void selectAllProducts(bool selected) {
    bulkEdit.clear();
    if(selected){
      for (var element in products) {
        element.isSelected = true;
        bulkEdit.add(
          {
            element.productId: {
              'agentsPrice': element.agentsPrice,
              'generalPrice': element.generalPrice,
              'architectPrice': element.architectPrice,
              'agentsDiscount': element.agentsDiscount,
              'generalDiscount': element.generalDiscount,
              'architectDiscount': element.architectDiscount,
              'costPrice': element.cost,
            },
          },
        );
      }
    } else {
      for (var element in products) {
        element.isSelected = false;
      }
    }
    notifyListeners();
  }
}
