import 'package:http/http.dart';
import 'package:msal_guard/msal_guard.dart';

class AuthenticationInterceptor extends Interceptor {
  final AuthenticationService _authService;
  AuthenticationInterceptor(this._authService);
  @override
  Future<BaseRequest> onRequest({required BaseRequest request}) async {
    //default to application/json
    if (!request.headers.keys
        .map((e) => e.toLowerCase())
        .contains('content-type')) {
      request.headers['Content-Type'] = 'application/json; charset=UTF-8';
    }
    request.headers.addEntries([await _authHeader]);
    return request;
  }

  Future<MapEntry<String, String>> get _authHeader async {
    String? token;
    try {
      token = (await _authService.acquireTokenSilently())?.accessToken;
    } catch (e) {
      token = (await _authService.acquireToken())?.accessToken;
    }

    //return
    return MapEntry('Authorization', "Bearer $token");
  }
}
