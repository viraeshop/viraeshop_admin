// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartAdapter extends TypeAdapter<Cart> {
  @override
  final int typeId = 0;

  @override
  Cart read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cart(
      productName: fields[0] as String,
      productId: fields[3] as int,
      productPrice: fields[1] as num,
      quantity: fields[2] as int,
      unitPrice: fields[4] as num,
      productCode: fields[10] as String,
      productImage: fields[11] as String,
      originalPrice: fields[12] as num,
      buyPrice: fields[9] as num,
      discountPercent: fields[5] as num,
      discount: fields[6] as num,
      isInventory: fields[7] as bool,
      supplierId: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Cart obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.productName)
      ..writeByte(1)
      ..write(obj.productPrice)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.productId)
      ..writeByte(4)
      ..write(obj.unitPrice)
      ..writeByte(5)
      ..write(obj.discountPercent)
      ..writeByte(6)
      ..write(obj.discount)
      ..writeByte(7)
      ..write(obj.isInventory)
      ..writeByte(8)
      ..write(obj.supplierId)
      ..writeByte(9)
      ..write(obj.buyPrice)
      ..writeByte(10)
      ..write(obj.productCode)
      ..writeByte(11)
      ..write(obj.productImage)
      ..writeByte(12)
      ..write(obj.originalPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
