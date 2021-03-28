import 'package:http/http.dart' as http;
import 'package:msal_guard/msal_guard.dart';

class AuthenticatedHttp {
  AuthenticationService authService;

  // get the auth service
  AuthenticatedHttp(this.authService);

  Future<http.Response> delete(Uri url,
      {Map<String, String>? headers, Object? body}) async {
    headers = await _addAuthHeaders(headers);
    return await http.delete(url, headers: headers, body: body);
  }

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    headers = await _addAuthHeaders(headers);
    return await http.get(url, headers: headers);
  }

  Future<http.Response> patch(Uri url,
      {Map<String, String>? headers, Object? body}) async {
    headers = await _addAuthHeaders(headers);
    return await http.patch(url, headers: headers, body: body);
  }

  Future<http.Response> post(Uri url,
      {Map<String, String>? headers, Object? body}) async {
    headers = await _addAuthHeaders(headers);

    return await http.post(url, headers: headers, body: body);
  }

  Future<Map<String, String>> _addAuthHeaders(
      Map<String, String>? headers) async {
    if (headers == null) {
      headers = new Map<String, String>();
    }

    String? token;
    try {
      token = await authService.acquireTokenSilently();
    } catch (MsalException) {
      token = await authService.acquireToken();
    }

    //add the auth bearer token
    headers["Authorization"] = "Bearer $token";

    //return
    return headers;
  }
}
