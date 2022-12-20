import 'package:flutter/material.dart';
import 'package:msal_guard/msal_guard.dart';
import 'package:provider/provider.dart';
import 'package:msal_flutter/msal_flutter.dart';

class PrivateWidget extends StatefulWidget {
  @override
  _PrivateWidgetState createState() => _PrivateWidgetState();
}

class _PrivateWidgetState extends State<PrivateWidget> {
  AuthenticationService? _authService;
  AuthenticatedHttp? _authHttp;
  String output = "-- output --";

  @override
  Widget build(BuildContext context) {
    _authHttp = context.read<AuthenticatedHttp>();
    _authService = context.read<AuthenticationService>();

    var textStyle = TextStyle(color: Colors.black87, fontSize: 16.0);

    return MaterialApp(builder: (context, child) {
      return Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Private area",
                style: textStyle,
              ),
              ElevatedButton(
                  onPressed: _callEndpoint,
                  child: Text('Make Authenticated call')),
              ElevatedButton(onPressed: _logout, child: Text('Logout')),
              Text(
                output,
                style: textStyle,
              )
            ],
          ),
        ),
      );
    });
  }

  _callEndpoint() async {
    try {
      var res = await _authHttp!.get("testauth");
      setState(() {
        output = res.body;
      });
    } on MsalException catch (e) {
      print(e);
      print(e.errorMessage);
    }
  }

  _logout() async {
    await _authService!.logout();
  }
}
