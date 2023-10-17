import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_placeholder_client/models/models.dart';
import 'package:json_placeholder_client/src/json_placeholder_client_exceptions.dart';

/// The JSON serializable model for the API response.
typedef JSON = Map<String, dynamic>;

/// When de API response is a List of [JSON].
typedef JSONLIST = List<JSON>;

/// APP Client to manage the API requests.
class JsonPlaceholderClient {
  /// Class constructor
  JsonPlaceholderClient() {
    _httpClient = http.Client();
  }

  /// The URL Authority for the queries.
  static const authority = 'jsonplaceholder.typicode.com';

  /// The HTTP Client;
  late final http.Client _httpClient;

  /// This methods returns a list of posts
  Future<List<Post>> getPosts({
    required int limit,
    int start = 0,
    int? userId,
  }) async {
    final uri = Uri.https(authority, '/posts', {
      '_limit': limit.toString(),
      '_start': start.toString(),
      if (userId != null) 'userId': userId.toString(),
    });

    final result = await _get<JSONLIST>(uri);

    try {
      return result.map(Post.fromMap).toList();
    } on FormatException {
      throw const SpecifiedTypeNotMatchedException();
    }
  }

  /// This method creates a new post with the specified parameters and returns a
  /// [Post] object.
  Future<Post> createPost({
    required String title,
    required String body,
  }) async {
    final uri = Uri.https(authority, '/posts');

    final result = await _post<JSON>(
      uri,
      body: {
        'title': title,
        'body': body,
        'userId': 1,
      },
    );

    try {
      return Post.fromMap(result);
    } on FormatException {
      throw const SpecifiedTypeNotMatchedException();
    }
  }

  Future<T> _post<T>(
    Uri uri, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool needsToken = true,
  }) async {
    http.Response response;

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
    http.Response response;

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

  T _handleResponse<T>(http.Response response) {
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
extension Result on http.Response {
  /// Returns true if the response is a success.
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// Returns true if the response is a failure.
  bool get isFailure => !isSuccess;
}
