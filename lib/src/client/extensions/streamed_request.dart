import 'package:http/http.dart';

extension StreamedRequestCopyWith on StreamedRequest {
  StreamedRequest copyWith({
    String? method,
    Uri? url,
    Map<String, String>? headers,
    Stream<List<int>>? stream,
    bool? followRedirects,
    int? maxRedirects,
    bool? persistentConnection,
  }) {
    final req = StreamedRequest(
      method ?? this.method,
      url ?? this.url,
    )
      ..headers.addAll(headers ?? this.headers)
      ..followRedirects = followRedirects ?? this.followRedirects
      ..maxRedirects = maxRedirects ?? this.maxRedirects
      ..persistentConnection =
          persistentConnection ?? this.persistentConnection;

    if (stream != null) {
      stream.listen((data) {
        req.sink.add(data);
      });
      finalize().listen((data) {
        req.sink.add(data);
      });
    }

    return req;
  }
}
