import 'package:http/http.dart';
export  'package:http/http.dart' show BaseRequest;

export './extensions/base_request.dart';

abstract class Interceptor {

  Future<BaseRequest> onRequest({required BaseRequest request});
}
