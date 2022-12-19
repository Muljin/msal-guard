import 'package:http/http.dart';

export './extensions/base_request.dart';

abstract class Interceptor {

  Future<BaseRequest> onRequest({required BaseRequest request});
}
