// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dua_cache_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DuaCacheAdapter extends TypeAdapter<DuaCache> {
  @override
  final int typeId = 1;

  @override
  DuaCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DuaCache(
      id: fields[0] as String,
      heading: fields[1] as String,
      arabic: fields[2] as String,
      english: fields[3] as String,
      malayalam: fields[4] as String,
      description: fields[5] as String,
      author: fields[6] as String,
      cachedAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DuaCache obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.heading)
      ..writeByte(2)
      ..write(obj.arabic)
      ..writeByte(3)
      ..write(obj.english)
      ..writeByte(4)
      ..write(obj.malayalam)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.author)
      ..writeByte(7)
      ..write(obj.cachedAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DuaCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
