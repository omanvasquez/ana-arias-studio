/// Clase base para excepciones de la aplicación.
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

class FirestoreException extends AppException {
  const FirestoreException(super.message, [super.code]);
}

class StorageException extends AppException {
  const StorageException(super.message, [super.code]);
}

class MedicalAlertBlockedException extends AppException {
  const MedicalAlertBlockedException(super.message, [super.code]);
}
