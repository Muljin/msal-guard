import 'package:msal_flutter/msal_flutter.dart';
import 'package:rxdart/rxdart.dart';

import './authentication_status.dart';

class AuthenticationService {
  /// Create a new authentication ser
  AuthenticationService(
      {required this.clientId,
      required this.defaultScopes,
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
  String? _currentAuthority;
  List<String> defaultScopes;

  // behavior subject
  final BehaviorSubject<AuthenticationStatus> _authenticationStatusSubject =
      BehaviorSubject<AuthenticationStatus>.seeded(AuthenticationStatus.none);

  /// Stream for updates to authentication status
  Stream<AuthenticationStatus> get authenticationStatus =>
      _authenticationStatusSubject.stream;

  /// Updates the authentication status
  void _updateStatus(AuthenticationStatus status) {
    var last = this._authenticationStatusSubject.value;
    if (status == last) {
      return;
    }
    _authenticationStatusSubject.add(status);
  }

  /// Initialisation function. Only to be called once on startup or first usage of auth service.
  /// @param defaultScopes A set of scopes which act as the default scopes for the app against its primary backend
  Future init({String? authorityOverride}) async {
    _currentAuthority = authorityOverride ?? authority;
    pca = await PublicClientApplication.createPublicClientApplication(
        this.clientId,
        authority: _currentAuthority,
        redirectUri: this.redirectUri,
        androidRedirectUri: this.androidRedirectUri,
        iosRedirectUri: this.iosRedirectUri);

    //store the default scopes for the app
    try {
      await acquireTokenSilently();
    } on MsalNoAccountException {
      _updateStatus(AuthenticationStatus.unauthenticated);
    }
  }

  Future<String> acquireToken({List<String>? scopes}) async {
    try {
      _pcaInitializedGuard();
      var res = await pca!.acquireToken(scopes ?? defaultScopes);
      _updateStatus(AuthenticationStatus.authenticated);
      return res;
    } catch (e) {
      _updateStatus(AuthenticationStatus.unauthenticated);
      throw e;
    }
  }

  Future<String> acquireTokenSilently({List<String>? scopes}) async {
    try {
      _pcaInitializedGuard();
      var res = await pca!.acquireTokenSilent(scopes ?? defaultScopes);
      _updateStatus(AuthenticationStatus.authenticated);
      return res;
    } catch (e) {
      _updateStatus(AuthenticationStatus.unauthenticated);
      throw e;
    }
  }

  Future login({String? authorityOverride}) async {
    print(_currentAuthority);
    try {
      // if override set, reinit with new authority
      if (pca == null || _currentAuthority != authorityOverride) {
        print("Logging in with a new authority");
        await init(authorityOverride: authorityOverride ?? authority);
      }

      print("Logging in");
      _updateStatus(AuthenticationStatus.authenticating);
      await pca!.acquireToken(defaultScopes);
      _updateStatus(AuthenticationStatus.authenticated);
    } catch (e) {
      _updateStatus(AuthenticationStatus.failed);
    }
  }

  Future logout() async {
    try {
      await pca!.logout();
    } finally {
      _updateStatus(AuthenticationStatus.unauthenticated);
    }
  }

  void dispose() {
    _authenticationStatusSubject.close();
  }

  /// Ensures PublicClientApplication is initialized before it is used.
  void _pcaInitializedGuard() {
    if (pca == null) {
      throw new MsalException(
          "PublicClientApplication must be initialized before use.");
    }
  }
}
