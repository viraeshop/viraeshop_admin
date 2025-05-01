// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shops_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShopAdapter extends TypeAdapter<Shop> {
  @override
  final int typeId = 1;

  @override
  Shop read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Shop(
      name: fields[0] as String,
      price: fields[4] as num,
      address: fields[3] as String,
      email: fields[1] as String,
      mobile: fields[2] as String,
      description: fields[9] as String,
      buyPrice: fields[8] as num,
      supplierId: fields[12] as int,
      due: fields[7] as dynamic,
      images: fields[10] as dynamic,
      payList: fields[11] as dynamic,
      paid: fields[6] as dynamic,
      profit: fields[5] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, Shop obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(12)
      ..write(obj.supplierId)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.mobile)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.profit)
      ..writeByte(6)
      ..write(obj.paid)
      ..writeByte(7)
      ..write(obj.due)
      ..writeByte(8)
      ..write(obj.buyPrice)
      ..writeByte(9)
      ..write(obj.description)
      ..writeByte(10)
      ..write(obj.images)
      ..writeByte(11)
      ..write(obj.payList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
