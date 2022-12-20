import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

import 'package:http/http.dart';

import 'authenticated_client.dart';
import 'interceptor.dart';

class AuthenticatedHttp {
  final AuthenticatedClient _inner;
  final String? _baseUrl;
  AuthenticatedHttp({
    List<Interceptor> interceptors = const [],
    String? baseUrl,
    Duration? requestTimeout,
    TimeoutCallback? onRequestTimeout,
    Client? client,
  })  : _baseUrl = _formatBaseUrl(baseUrl),
        _inner = AuthenticatedClient(
            interceptors: interceptors,
            requestTimeout: requestTimeout,
            onRequestTimeout: onRequestTimeout,
            client: client);

  Future<Response> delete(String path,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return _inner.delete(_getFullUrl(path),
        headers: headers, body: body, encoding: encoding);
  }

  Future<Response> get(String path, {Map<String, String>? headers}) {
    return _inner.get(_getFullUrl(path), headers: headers);
  }

  Future<Response> head(String path, {Map<String, String>? headers}) {
    return _inner.head(_getFullUrl(path), headers: headers);
  }

  Future<Response> patch(String path,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return _inner.patch(_getFullUrl(path),
        headers: headers, body: body, encoding: encoding);
  }

  Future<Response> post(String path,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return _inner.post(_getFullUrl(path),
        headers: headers, body: body, encoding: encoding);
  }

  Future<Response> put(String path,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return _inner.put(_getFullUrl(path),
        headers: headers, body: body, encoding: encoding);
  }

  Future<String> read(String path, {Map<String, String>? headers}) {
    return _inner.read(_getFullUrl(path), headers: headers);
  }

  Future<Uint8List> readBytes(String path, {Map<String, String>? headers}) {
    return _inner.readBytes(_getFullUrl(path), headers: headers);
  }

  static String? _formatBaseUrl(String? url) {
    if (url == null) {
      return url;
    }

    if (url.endsWith("/")) {
      url = url.substring(0, url.length - 1);
    }

    return url;
  }

  Uri _getFullUrl(String url) {
    //if base not set, or is full url, return
    if (_baseUrl == null ||
        url.toLowerCase().startsWith("http://") ||
        url.toLowerCase().startsWith("https://")) {
      print("base url was null");
      return Uri.parse(url);
    }

    if (!url.startsWith("/")) {
      url = "/$url";
    }
    return Uri.parse("$_baseUrl$url");
  }
}
