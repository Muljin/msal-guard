import 'package:flutter/material.dart';
import 'package:msal_guard/msal_guard.dart';
import 'package:provider/provider.dart';

/// Create a new MsalGuard widget
/// @param publicWidget The widget to display when user is not authenticated
/// @param guardedWidget The widget to display when user is authenticated
/// @param loadingWidget the widget to display when transitioning between states and authenticating
/// @param clientId the client id of the client applciation in Azure AD
/// @param scopes The default scopes to be used on the app against its main API endpoint. Default scopes used for login and checking auth status
/// @param authority The authority url to authenticate against
/// @param redirectUri the redirect uri
/// @param androidRedirectUri redirect uri override for android
/// @param iosRedirectUri redirect uri override for iOS
/// @param apiBaseUrl The base url of the api against which authenticated calls will be made. Used for authenticated_http service to allow calling paths.
class MsalGuard extends StatefulWidget {
  const MsalGuard(
      {Key? key,
      required this.publicWidget,
      required this.guardedWidget,
      required this.loadingWidget,
      required this.clientId,
      required this.scopes,
      this.authority,
      this.additionalAuthorities,
      this.redirectUri,
      this.androidRedirectUri,
      this.iosRedirectUri,
      this.keychain,
      this.privateSession,
      this.apiBaseUrl})
      : super(key: key);

  final Widget publicWidget;
  final Widget guardedWidget;
  final Widget loadingWidget;

  final String clientId;
  final String? authority;
  final List<String>? additionalAuthorities;
  final String? redirectUri;
  final List<String> scopes;

  final String? apiBaseUrl;

  /// this is only used in ios it won't affect android configuration
  /// for more info go to https://docs.microsoft.com/en-us/azure/active-directory/develop/single-sign-on-macos-ios#silent-sso-between-apps
  final String? keychain;
  /// privateSession is set to true to request that the browser doesn’t share cookies or other browsing data between the authentication session and the user’s normal browser session. Whether the request is honored depends on the user’s default web browser. Safari always honors the request.
  /// The value of this property is false by default.
  final bool? privateSession;

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
      iosRedirectUri: iosRedirectUri,
      keychain: keychain,
      privateSession: privateSession,
      apiBaseUrl: apiBaseUrl);
}

class _MsalGuardState extends State<MsalGuard> {
  final String clientId;
  final List<String> scopes;
  final String? authority;
  final String? redirectUri;
  final String? androidRedirectUri;
  final String? iosRedirectUri;
  final String? apiBaseUrl;
  final String? keychain;
  final bool? privateSession;

  late AuthenticationService _authenticationService;

  _MsalGuardState({
    required this.clientId,
    required this.scopes,
    this.authority,
    this.redirectUri,
    this.androidRedirectUri,
    this.iosRedirectUri,
    this.apiBaseUrl,
    this.privateSession,
    this.keychain,
  }) {
    _authenticationService = AuthenticationService(
        clientId: this.clientId,
        defaultScopes: scopes,
        defaultAuthority: this.authority,
        redirectUri: this.redirectUri,
        keychain: this.keychain,
        iosRedirectUri: this.iosRedirectUri,
        privateSession: privateSession,
        androidRedirectUri: this.androidRedirectUri);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      print("Initialising auth");
      _authenticationService.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<AuthenticationService>(
              create: (_) => _authenticationService),
          Provider<AuthenticatedHttp>(
              create: (_) => AuthenticatedHttp(_authenticationService,
                  baseUrl: apiBaseUrl))
        ],
        builder: (context, wiget) => StreamBuilder(
              // initialData: widget.loadingWidget,
              stream: _authenticationService.authenticationStatus,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return widget.loadingWidget;
                }
                if (snapshot.data == AuthenticationStatus.unauthenticated ||
                    snapshot.data == AuthenticationStatus.failed) {
                  return widget.publicWidget;
                } else if (snapshot.data ==
                    AuthenticationStatus.authenticated) {
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
