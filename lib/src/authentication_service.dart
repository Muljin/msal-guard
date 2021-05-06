import 'package:msal_flutter/msal_flutter.dart';
import 'package:rxdart/rxdart.dart';

import './authentication_status.dart';

class AuthenticationService {
  /// Create a new authentication ser
  AuthenticationService(
      {required this.clientId,
      required this.defaultScopes,
      this.defaultAuthority,
      this.additionalAuthorities,
      this.redirectUri,
      this.androidRedirectUri,
      this.iosRedirectUri});

  final String clientId;
  final String? defaultAuthority;
  final String? redirectUri;
  final String? androidRedirectUri;
  final String? iosRedirectUri;
  final List<String>? additionalAuthorities;

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
    if(await _initAuthority(authorityOverride ?? defaultAuthority)){

    }else{

    }
  }

  Future initAll() async {
    if (await _initAuthority(_currentAuthority) ||
        await _tryInitNoneDefaultAuthorities()) {
      _updateStatus(AuthenticationStatus.authenticated);
    } else {
      _updateStatus(AuthenticationStatus.unauthenticated);
    }
  }

  //initiate an authority
  Future<bool> _initAuthority(String? authority) async {
    _currentAuthority = authority;
    pca = await PublicClientApplication.createPublicClientApplication(
        this.clientId,
        authority: authority,
        redirectUri: this.redirectUri,
        androidRedirectUri: this.androidRedirectUri,
        iosRedirectUri: this.iosRedirectUri);

    //store the default scopes for the app
    try {
      await acquireTokenSilently();
      return true;
    } on Exception {
      print("Authority $authority Failed");
      return false;
    }
  }

  //try init all none default authorities until one works
  Future<bool> _tryInitNoneDefaultAuthorities() async {
    print("Trying to initialize none default");
    if (additionalAuthorities == null || additionalAuthorities!.length == 0) {
      print("None default null or empty");
      return false;
    }
    for (var a in additionalAuthorities!) {
      print("None default loop.");
      if (await _initAuthority(a)) {
        return true;
      }
    }
    return false;
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
    var authority = authorityOverride ?? defaultAuthority;

    try {
      // if override set, reinit with new authority
      if (pca == null ||  _currentAuthority != authority) {
        print("Logging in with a new authority");
        await init(authorityOverride: authority);
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
