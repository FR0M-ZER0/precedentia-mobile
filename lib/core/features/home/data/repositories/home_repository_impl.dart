import 'package:precedentia_mobile/core/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<String> getMessage() async {
    return "Hello, World!";
  }
}
