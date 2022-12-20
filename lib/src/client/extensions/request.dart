import 'dart:convert';

import 'package:http/http.dart';

extension RequestCopyWith on Request {
  Request copyWith({
    String? method,
    Uri? url,
    Map<String, String>? headers,
    String? body,
    List<int>? bodyBytes,
    Encoding? encoding,
    bool? followRedirects,
    int? maxRedirects,
    bool? persistentConnection,
  }) {
    final copied = Request(
      method ?? this.method,
      url ?? this.url,
    )..body = this.body;

    if (body != null) {
      copied.body = body;
    }

    if (bodyBytes != null) {
      copied.bodyBytes = bodyBytes;
    }

    return copied
      ..headers.addAll(headers ?? this.headers)
      ..encoding = encoding ?? this.encoding
      ..followRedirects = followRedirects ?? this.followRedirects
      ..maxRedirects = maxRedirects ?? this.maxRedirects
      ..persistentConnection =
          persistentConnection ?? this.persistentConnection;
  }
}
