import 'package:flutter/material.dart';
import 'package:msal_guard/msal_guard.dart';
import 'package:provider/provider.dart';

class LoginWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Column(
          children: [
            Text('Login page example'),
            ElevatedButton(
                onPressed: context.read<AuthenticationService>().login,
                child: Text('Login'))
          ],
        ));
  }
}
