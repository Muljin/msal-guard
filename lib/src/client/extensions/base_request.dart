import 'dart:convert';

import 'package:http/http.dart';

import './multipart_request.dart';
import './request.dart';
import './streamed_request.dart';

extension BaseRequestCopyWith on BaseRequest {
  BaseRequest copyWith({
    String? method,
    Uri? url,
    Map<String, String>? headers,
    bool? followRedirects,
    int? maxRedirects,
    bool? persistentConnection,
    // Request only variables.
    dynamic body,
    Encoding? encoding,
    // MultipartRequest only properties.
    Map<String, String>? fields,
    List<MultipartFile>? files,
    // StreamedRequest only properties.
    Stream<List<int>>? stream,
  }) {
    if (this is Request) {
      return RequestCopyWith(this as Request).copyWith(
        method: method,
        url: url,
        headers: headers,
        body: body,
        encoding: encoding,
        followRedirects: followRedirects,
        maxRedirects: maxRedirects,
        persistentConnection: persistentConnection,
      );
    } else if (this is StreamedRequest) {
      return StreamedRequestCopyWith(this as StreamedRequest).copyWith(
        method: method,
        url: url,
        headers: headers,
        stream: stream,
        followRedirects: followRedirects,
        maxRedirects: maxRedirects,
        persistentConnection: persistentConnection,
      );
    } else if (this is MultipartRequest) {
      return MultipartRequestCopyWith(this as MultipartRequest).copyWith(
        method: method,
        url: url,
        headers: headers,
        fields: fields,
        files: files,
        followRedirects: followRedirects,
        maxRedirects: maxRedirects,
        persistentConnection: persistentConnection,
      );
    }

    throw UnsupportedError(
        'Cannot copy unsupported type of request $runtimeType');
  }
}
