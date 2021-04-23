import 'package:http/http.dart' as http;
import 'package:msal_guard/msal_guard.dart';

class AuthenticatedHttp {
  AuthenticationService authService;
  final String? _baseUrl;

  // get the auth service
  AuthenticatedHttp(this.authService, {String? baseUrl})
      : _baseUrl = _formatBaseUrl(baseUrl);

  Future<http.Response> delete(String url,
      {Map<String, String>? headers, Object? body}) async {
    headers = await _addAuthHeaders(headers);
    return await http.delete(_getFullUrl(url), headers: headers, body: body);
  }

  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    headers = await _addAuthHeaders(headers);
    return await http.get(_getFullUrl(url), headers: headers);
  }

  Future<http.Response> patch(String url,
      {Map<String, String>? headers, Object? body}) async {
    headers = await _addAuthHeaders(headers);
    return await http.patch(_getFullUrl(url), headers: headers, body: body);
  }

  Future<http.Response> post(String url,
      {Map<String, String>? headers, Object? body}) async {
    headers = await _addAuthHeaders(headers);

    return await http.post(_getFullUrl(url), headers: headers, body: body);
  }

  Future<Map<String, String>> _addAuthHeaders(
      Map<String, String>? headers) async {
    if (headers == null) {
      headers = new Map<String, String>();
    }

    //default to application/json
    if (!headers.keys.map((e) => e.toLowerCase()).contains('content-type')) {
      headers['Content-Type'] = 'application/json; charset=UTF-8';
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

  static String? _formatBaseUrl(String? url) {
    if (url == null) {
      return url;
    }

    if (url.endsWith("/")) {
      url = url.substring(0, url.length - 1);
    }

    return url;
  }

  /// returns the complete url, adding baseurl if given url is path
  Uri _getFullUrl(String url) {
    //if base not set, or is full url, return
    if (_baseUrl == null ||
        url.toLowerCase().startsWith("http://") ||
        url.toLowerCase().startsWith("https://")) {
      print("base url was null");
      return Uri.parse(url);
    }

    if (!url.startsWith("/")) {
      url = "/" + url;
    }
    return Uri.parse("$_baseUrl$url");
  }
}
