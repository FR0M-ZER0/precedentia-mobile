abstract class Failure {
  final String message;
  Failure({this.message = ""});
}

class ServerFailure extends Failure {
  ServerFailure({super.message = "Erro de comunicação com o servidor"});
}

class CacheFailure extends Failure {
  CacheFailure({super.message = "Erro ao acessar os dados locais"});
}
