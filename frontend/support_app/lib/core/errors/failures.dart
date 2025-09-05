abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure([super.message = 'Server error occurred']);
}

class CacheFailure extends Failure {
  CacheFailure([super.message = 'Cache error occurred']);
}