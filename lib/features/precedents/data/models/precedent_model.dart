import 'package:hive/hive.dart';
import '../../domain/precedent.dart';

part 'precedent_model.g.dart';

@HiveType(typeId: 1)
class PrecedentModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String titulo;

  @HiveField(2)
  final String ementa;

  @HiveField(3)
  final DateTime dataAcesso;

  PrecedentModel({
    required this.id,
    required this.titulo,
    required this.ementa,
    required this.dataAcesso,
  });

  factory PrecedentModel.fromJson(Map<String, dynamic> json) => PrecedentModel(
    id: json['id'],
    titulo: json['titulo'],
    ementa: json['ementa'],
    dataAcesso: DateTime.now(),
  );

  Precedent toDomain() => Precedent(id: id, titulo: titulo, ementa: ementa);
}
