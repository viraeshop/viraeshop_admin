import 'package:hive/hive.dart';

part 'shops_model.g.dart';

const List ima = [];
@HiveType(typeId: 1)
class Shop {  
  @HiveField(0)
  String name;
  @HiveField(1)
  String email;
  @HiveField(2)
  String mobile;
  @HiveField(3)
  String address;
  @HiveField(4)
  num price;
  @HiveField(5)
  var profit;
  @HiveField(6)
  var paid;
  @HiveField(7)
  var due;
  @HiveField(8)
  num buyPrice;
  @HiveField(9)
  String description;
  @HiveField(10)
  var images;
  @HiveField(11)
  var payList;

  Shop({
    required this.name,
    required this.price,
    required this.address,
    required this.email,
    required this.mobile,
    required this.description,
    required this.buyPrice,
    this.due = 0,
    this.images = ima,
    this.payList = ima,
    this.paid = 0,
    this.profit = 0,
  });
}
