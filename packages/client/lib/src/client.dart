import 'dart:convert';

import 'package:client/src/client_exceptions.dart';
import 'package:http_interceptor/http_interceptor.dart' as http_interceptor;

/// The JSON serializable model for the API response.
typedef JSON = Map<String, dynamic>;

/// When de API response is a List of [JSON].
typedef JSONLIST = List<JSON>;

/// APP Client to manage the API requests.
class Client {
  late final http_interceptor.Client _httpClient;

  Future<T> _post<T>(
    Uri uri, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool needsToken = true,
  }) async {
    http_interceptor.Response response;

    try {
      response = await _httpClient.post(
        uri,
        body: (body != null) ? jsonEncode(body) : null,
        headers: {
          ..._headersAlways,
          'needs-token': '$needsToken',
        },
      );
    } catch (_) {
      throw HttpException();
    }

    return _handleResponse<T>(response);
  }

  Future<T> _get<T>(
    Uri uri, {
    bool needsToken = true,
  }) async {
    http_interceptor.Response response;

    try {
      response = await _httpClient.get(
        uri,
        headers: {
          ..._headersAlways,
          'needs-token': '$needsToken',
        },
      );
    } catch (_) {
      throw HttpException();
    }

    return _handleResponse<T>(response);
  }

  Future<T> _put<T>(
    Uri uri, {
    Map<String, dynamic>? body,
    bool needsToken = true,
  }) async {
    http_interceptor.Response response;

    try {
      response = await _httpClient.put(
        uri,
        body: (body != null) ? jsonEncode(body) : null,
        headers: {
          ..._headersAlways,
          'needs-token': '$needsToken',
        },
      );
    } catch (_) {
      throw HttpException();
    }

    return _handleResponse<T>(response);
  }

  Future<T> _delete<T>(
    Uri uri, {
    Map<String, dynamic>? body,
    bool needsToken = true,
  }) async {
    http_interceptor.Response response;

    try {
      response = await _httpClient.delete(
        uri,
        body: (body != null) ? jsonEncode(body) : null,
        headers: {
          ..._headersAlways,
          'needs-token': '$needsToken',
        },
      );
    } catch (_) {
      throw HttpException();
    }

    return _handleResponse<T>(response);
  }

  T _handleResponse<T>(http_interceptor.Response response) {
    try {
      if (response is T) return response as T;

      final dynamic decodedResponse = jsonDecode(response.body);

      if (response.isFailure && decodedResponse is Map<String, dynamic>) {
        if (decodedResponse.containsKey('exception')) {
          // throw ExceptionResponse.fromMap(decodedResponse);
        }
        throw HttpRequestFailure(
          response.statusCode,
          response.reasonPhrase ?? '',
        );
      }

      if (decodedResponse is T) return decodedResponse;

      try {
        if (T == JSON) {
          (decodedResponse as Map).cast<String, dynamic>() as T;
        } else if (T == JSONLIST) {
          final newResponse = (decodedResponse as List)
              .map<JSON>(
                (dynamic item) => (item as Map).cast<String, dynamic>(),
              )
              .toList();
          return newResponse as T;
        }

        return decodedResponse as T;
      } catch (_) {
        throw const SpecifiedTypeNotMatchedException();
      }
    } on FormatException {
      throw const JsonDecodeException();
    }
  }

  Map<String, String> get _headersAlways => <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };
}

/// A class to make it easier to handle the response from the API.
extension Result on http_interceptor.Response {
  /// Returns true if the response is a success.
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// Returns true if the response is a failure.
  bool get isFailure => !isSuccess;
}
