import 'dart:async';

import 'package:http/http.dart';

import 'interceptor.dart';

typedef TimeoutCallback = FutureOr<StreamedResponse> Function();

class AuthenticatedClient extends BaseClient {
  final List<Interceptor> interceptors;

  final Duration? requestTimeout;

  FutureOr<StreamedResponse> Function()? onRequestTimeout;

  late final Client _inner;
  AuthenticatedClient({
    this.interceptors = const [],
    this.requestTimeout,
    this.onRequestTimeout,
    Client? client,
  }) : _inner = client ?? Client();

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final response = await _attemptRequest(request);

    return response as StreamedResponse;
  }

  Future<BaseResponse> _attemptRequest(BaseRequest request) async {
    try {
      BaseResponse response;
      // Intercept request
      final interceptedRequest = await _interceptRequest(request);

      response = requestTimeout == null
          ? await _inner.send(interceptedRequest)
          : await _inner
              .send(interceptedRequest)
              .timeout(requestTimeout!, onTimeout: onRequestTimeout);
      return response;
    } on Exception {
      rethrow;
    } finally {
      _inner.close();
    }
  }

  Future<BaseRequest> _interceptRequest(BaseRequest request) async {
    BaseRequest interceptedRequest = request.copyWith();
    for (Interceptor interceptor in interceptors) {
      interceptedRequest = await interceptor.onRequest(
        request: interceptedRequest,
      );
    }

    return interceptedRequest;
  }

  @override
  void close() {
    _inner.close();
  }
}
