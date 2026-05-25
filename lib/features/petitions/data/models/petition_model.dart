import 'package:hive/hive.dart';

part 'petition_model.g.dart';

@HiveType(typeId: 2)
class PetitionModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String filePath;

  @HiveField(2)
  final DateTime sentAt;

  PetitionModel({
    required this.name,
    required this.filePath,
    required this.sentAt,
  });
}
