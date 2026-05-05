// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'petition_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetitionModelAdapter extends TypeAdapter<PetitionModel> {
  @override
  final int typeId = 2;

  @override
  PetitionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetitionModel(
      name: fields[0] as String,
      filePath: fields[1] as String,
      sentAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PetitionModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.sentAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetitionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
