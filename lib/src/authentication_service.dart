import 'package:msal_flutter/msal_flutter.dart';
import 'package:rxdart/rxdart.dart';

import './authentication_status.dart';

class AuthenticationService {
  /// Create a new authentication ser
  AuthenticationService(
      {required this.clientId,
      this.authority,
      this.redirectUri,
      this.androidRedirectUri,
      this.iosRedirectUri});

  final String clientId;
  final String? authority;
  final String? redirectUri;
  final String? androidRedirectUri;
  final String? iosRedirectUri;

  PublicClientApplication? pca;

  // behavior subject
  final BehaviorSubject<AuthenticationStatus> _authenticationStatusSubject =
      BehaviorSubject<AuthenticationStatus>.seeded(AuthenticationStatus.none);

  /// Stream for updates to authentication status
  Stream<AuthenticationStatus> get authenticationStatus =>
      _authenticationStatusSubject.stream;

  void _updateStatus(AuthenticationStatus status) {
    var last = this._authenticationStatusSubject.value;
    if (status == last) {
      return;
    }
    _authenticationStatusSubject.add(status);
  }

  /// Initialisation function. Only to be called once on startup or first usage of auth service
  Future init(List<String> scopes) async {
    pca = await PublicClientApplication.createPublicClientApplication(
        this.clientId,
        authority: this.authority,
        redirectUri: this.redirectUri,
        androidRedirectUri: this.androidRedirectUri,
        iosRedirectUri: this.iosRedirectUri);
    // try get token silently
    try {
      print("Getting token");
      print(this.authority);
      var res = await pca!.acquireToken(scopes);
      print("got token");
      print(res);
      _updateStatus(AuthenticationStatus.authenticated);
    } catch (e) {
      print("Caught exception");
      _updateStatus(AuthenticationStatus.unauthenticated);
    }
  }

  void dispose() {
    _authenticationStatusSubject.close();
  }
}
