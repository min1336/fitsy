class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error']);
}

class AIException implements Exception {
  final String message;
  const AIException([this.message = 'AI processing error']);
}
