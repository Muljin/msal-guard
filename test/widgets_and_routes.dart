import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Route<dynamic> onProtected(RouteSettings settings) {
  return CupertinoPageRoute(
    builder: (context) => ProtectedWidget(),
  );
}

class ProtectedWidget extends StatelessWidget {
  const ProtectedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Protected'),
    );
  }
}
Route<dynamic> onPublic(RouteSettings settings) {
  return CupertinoPageRoute(
    builder: (context) => PublicWidget(),
  );
}
class PublicWidget extends StatelessWidget {
  const PublicWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Public'),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Loading'),
    );
  }
}
