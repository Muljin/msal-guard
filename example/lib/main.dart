import 'dart:developer';

import 'package:example/loading.dart';
import 'package:example/login.dart';
import 'package:example/private.dart';
import 'package:flutter/material.dart';
import 'package:msal_guard/msal_guard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String _authority =
      "https://msalfluttertest.b2clogin.com/tfp/3fab2993-1fec-4a8c-a6d8-2bfea01e64ea/B2C_1_phonesisu";
  static const String _iosRedirectUri = "msauth.com.muljin.msalguardexample://auth";
  static const String _androidRedirectUri =
      "msauth://com.example.example/TvkGQnk1ERb%2Bl9pB4OeyeWrYmqo%3D";
  static const String _clientId = "fc6136e7-43d1-489c-b221-630e9e4402d3";
  static const List<String> _scopes = [
    "https://msalfluttertest.onmicrosoft.com/msaltesterapi/All"
  ];

  static const String _apiUrl = "https://msalflutterapi.azurewebsites.net";

  @override
  Widget build(BuildContext context) {
    return MsalGuard(
      publicWidget: LoginWidget(),
      guardedWidget: PrivateWidget(),
      loadingWidget: LoadingWidget(),
      clientId: _clientId,
      authority: _authority,
      redirectUri: _androidRedirectUri,
      iosRedirectUri: _iosRedirectUri,
      httpInterceptors: [TestInterceptor()],
      scopes: _scopes,
      apiBaseUrl: _apiUrl,
    );
  }
}

class TestInterceptor extends Interceptor {
  @override
  Future<BaseRequest> onRequest({required BaseRequest request}) async {
    log("intercepted request");
    return request;
  }
}
