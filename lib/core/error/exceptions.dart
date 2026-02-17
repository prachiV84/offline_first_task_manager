/// Base exception class
class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache exception occurred']);
}

/// Validation exception
class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
}
