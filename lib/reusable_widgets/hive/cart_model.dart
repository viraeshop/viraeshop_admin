import 'package:hive/hive.dart';

part 'cart_model.g.dart';

@HiveType(typeId: 0)
class Cart {
  @HiveField(0)
  String productName;
  @HiveField(1)
  var price;
  @HiveField(2)
  int quantity;
  @HiveField(3)
  String productId;
  @HiveField(4)
  num unitPrice;
  @HiveField(5)
  num discountPercent;
  @HiveField(6)
  num discountValue;
  @HiveField(7)
  bool? isInventory;
  @HiveField(8)
  String shopName;
  @HiveField(9)
  num buyPrice;


  Cart({
    required this.productName,
    required this.productId,
    required this.price,
    required this.quantity,
    required this.unitPrice,
    this.buyPrice = 0,
    this.discountPercent = 0,
    this.discountValue = 0,
    this.isInventory = true,
    this.shopName = '',
  });
}
