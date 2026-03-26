abstract class Failure {
  final String message;
  
  Failure({this.message = ""});
}

// Representa um erro vindo da comunicação com a API (via Dio)
class ServerFailure extends Failure {
  ServerFailure({String message = "Erro de comunicação com o servidor"}) 
      : super(message: message);
}

// Representa um erro vindo do armazenamento local (via Hive ou Secure Storage)
class CacheFailure extends Failure {
  CacheFailure({String message = "Erro ao acessar os dados locais"}) 
      : super(message: message);
}

// Caso futuramente tivermos erros de validação de formulario tipo:
// class ValidationFailure extends Failure { ... }