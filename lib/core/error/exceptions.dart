class ServerException implements Exception {
  final String message;
  final int? code;

  const ServerException({this.message = 'Server error occurred', this.code});

  @override
  String toString() => 'ServerException: $message (code: $code)';
}

class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Cache error occurred'});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'No internet connection'});

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException({this.message = 'Authentication failed', this.code});

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

class FirebaseException implements Exception {
  final String message;
  final String? code;

  const FirebaseException({this.message = 'Firebase error occurred', this.code});

  @override
  String toString() => 'FirebaseException: $message (code: $code)';
}

class ValidationException implements Exception {
  final String message;

  const ValidationException({this.message = 'Validation failed'});

  @override
  String toString() => 'ValidationException: $message';
}
