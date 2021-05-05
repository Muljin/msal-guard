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
                child: Text('Login')),
            ElevatedButton(
              onPressed: () => context.read<AuthenticationService>().login(
                  authorityOverride:
                      "https://msalfluttertest.b2clogin.com/tfp/3fab2993-1fec-4a8c-a6d8-2bfea01e64ea/B2C_1_phone"),
              child: Text("Login with Google"),
            )
          ],
        ));
  }
}
