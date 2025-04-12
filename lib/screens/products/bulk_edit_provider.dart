import 'package:flutter/foundation.dart';
import 'package:viraeshop_admin/screens/products/bulk_edit_product.dart';

class BulkEditProvider with ChangeNotifier {
  List<ProductEntity> products = [];
  List<Map<String, dynamic>> bulkEdit = [];

  void setProducts(List<ProductEntity> value) {
    products = value;
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
          },
        },
      );
    } else {
      bulkEdit.removeWhere((element) => element.containsKey(productId));
    }
    notifyListeners();
  }
}
