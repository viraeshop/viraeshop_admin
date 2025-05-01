import 'package:hive/hive.dart';

part 'cart_model.g.dart';

@HiveType(typeId: 0)
class Cart {
  @HiveField(0)
  String productName;
  @HiveField(1)
  num productPrice;
  @HiveField(2)
  int quantity;
  @HiveField(3)
  int productId;
  @HiveField(4)
  num unitPrice;
  @HiveField(5)
  num discountPercent;
  @HiveField(6)
  num discount;
  @HiveField(7)
  bool isInventory;
  @HiveField(8)
  int supplierId;
  @HiveField(9)
  num buyPrice;
  @HiveField(10)
  String productCode;
  @HiveField(11)
  String productImage;
  @HiveField(12)
  num originalPrice;




  Cart({
    required this.productName,
    required this.productId,
    required this.productPrice,
    required this.quantity,
    required this.unitPrice,
    required this.productCode,
    required this.productImage,
    required this.originalPrice,
    this.buyPrice = 0,
    this.discountPercent = 0,
    this.discount = 0,
    this.isInventory = true,
    this.supplierId = 0,
  });
}
