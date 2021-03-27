import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'authentication_service.dart';
import 'authentication_status.dart';

class MsalGuard extends StatefulWidget {
  const MsalGuard(
      {Key? key,
      required this.publicWidget,
      required this.guardedWidget,
      required this.loadingWidget,
      required this.clientId,
      required this.scopes,
      this.authority,
      this.redirectUri,
      this.androidRedirectUri,
      this.iosRedirectUri})
      : super(key: key);

  final Widget publicWidget;
  final Widget guardedWidget;
  final Widget loadingWidget;

  final String clientId;
  final String? authority;
  final String? redirectUri;
  final List<String> scopes;

  //redirect uri overrides
  final String? androidRedirectUri;
  final String? iosRedirectUri;

  @override
  _MsalGuardState createState() => _MsalGuardState(
      clientId: clientId,
      scopes: scopes,
      authority: authority,
      redirectUri: redirectUri,
      androidRedirectUri: androidRedirectUri,
      iosRedirectUri: iosRedirectUri);
}

class _MsalGuardState extends State<MsalGuard> {
  final String clientId;
  final List<String> scopes;
  final String? authority;
  final String? redirectUri;
  final String? androidRedirectUri;
  final String? iosRedirectUri;

  late AuthenticationService _authenticationService;

  _MsalGuardState(
      {required this.clientId,
      required this.scopes,
      this.authority,
      this.redirectUri,
      this.androidRedirectUri,
      this.iosRedirectUri}) {
    _authenticationService = AuthenticationService(
        clientId: this.clientId,
        authority: this.authority,
        redirectUri: this.redirectUri,
        iosRedirectUri: this.iosRedirectUri,
        androidRedirectUri: this.androidRedirectUri);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      print("Initialising auth");
      _authenticationService.init(scopes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthenticationService>(
        create: (_) => _authenticationService,
        child: StreamBuilder(
          initialData: widget.loadingWidget,
          stream: _authenticationService.authenticationStatus,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return widget.loadingWidget;
            }
            if (snapshot.data == AuthenticationStatus.unauthenticated) {
              return widget.publicWidget;
            } else if (snapshot.data == AuthenticationStatus.authenticated) {
              return widget.guardedWidget;
            } else {
              return widget.loadingWidget;
            }
          },
        ));
  }

  @override
  void dispose() {
    _authenticationService.dispose();
    super.dispose();
  }
}
