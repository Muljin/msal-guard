import 'package:http/http.dart';

extension MultipartRequestCopyWith on MultipartRequest {
  MultipartRequest copyWith({
    String? method,
    Uri? url,
    Map<String, String>? headers,
    Map<String, String>? fields,
    List<MultipartFile>? files,
    bool? followRedirects,
    int? maxRedirects,
    bool? persistentConnection,
  }) =>
      MultipartRequest(
        method ?? this.method,
        url ?? this.url,
      )
        ..headers.addAll(headers ?? this.headers)
        ..fields.addAll(fields ?? this.fields)
        ..files.addAll(files ?? this.files)
        ..followRedirects = followRedirects ?? this.followRedirects
        ..maxRedirects = maxRedirects ?? this.maxRedirects
        ..persistentConnection =
            persistentConnection ?? this.persistentConnection;
}
