// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'precedent_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrecedentModelAdapter extends TypeAdapter<PrecedentModel> {
  @override
  final int typeId = 1;

  @override
  PrecedentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrecedentModel(
      id: fields[0] as String,
      titulo: fields[1] as String,
      ementa: fields[2] as String,
      dataAcesso: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PrecedentModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.titulo)
      ..writeByte(2)
      ..write(obj.ementa)
      ..writeByte(3)
      ..write(obj.dataAcesso);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrecedentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
