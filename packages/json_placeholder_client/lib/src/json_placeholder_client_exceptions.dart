/// Thrown if an exception occurs while making an http request.
class HttpException implements Exception {}

/// Thrown if an http request returns a non-200 status code.
class HttpRequestFailure implements Exception {
  /// Class constructor.
  const HttpRequestFailure(this.statusCode, this.error);

  /// The status code of the response.
  final int statusCode;

  /// The error message of the response.
  final String error;

  @override
  String toString() =>
      'HttpRequestFailure(statusCode: $statusCode, error: $error)';
}

/// Thrown when an error occurs while decoding the response body.
class JsonDecodeException implements Exception {
  /// Thrown when an error occurs while decoding the response body.
  const JsonDecodeException();
}

/// Thrown when an error occurs while decoding the response body.
class SpecifiedTypeNotMatchedException implements Exception {
  /// Thrown when an error occurs while decoding the response body.
  const SpecifiedTypeNotMatchedException();
}
