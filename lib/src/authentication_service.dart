import 'dart:io';

import 'package:msal_flutter/msal_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../msal_guard.dart';

const String _kDefaultUser = 'defaultUser';

class AuthenticationService {
  late SharedPreferences _prefs;

  late MSALPublicClientApplication _pca;

  final MSALPublicClientApplicationConfig config;
  final MSALWebviewParameters? webParams;
  final MSALInteractiveTokenParameters _defaultInteractiveParams;
  final MSALSilentTokenParameters _defaultSilentParams;
  final MSALSignoutParameters _defaultSignoutParameters;

  AuthenticationService({
    required this.config,
    required List<String> defaultScopes,
    this.webParams,
  })  : this._defaultInteractiveParams =
            MSALInteractiveTokenParameters(scopes: defaultScopes),
        this._defaultSilentParams =
            MSALSilentTokenParameters(scopes: defaultScopes),
        this._defaultSignoutParameters = MSALSignoutParameters();

  late MSALAccount? _currentAccount;
  MSALAccount? get currentAccount => _currentAccount;

  BehaviorSubject<List<MSALAccount>?> _accountSubject =
      BehaviorSubject<List<MSALAccount>?>.seeded(null);

  Stream<List<MSALAccount>?> get accounts => _accountSubject.stream;
  // behavior subject
  final BehaviorSubject<AuthenticationStatus> _authenticationStatusSubject =
      BehaviorSubject<AuthenticationStatus>.seeded(AuthenticationStatus.none);

  /// Stream for updates to authentication status
  Stream<AuthenticationStatus> get authenticationStatus =>
      _authenticationStatusSubject.stream;

  /// Updates the authentication status
  void _updateStatus(AuthenticationStatus status) {
    var last = _authenticationStatusSubject.value;
    if (status == last) {
      return;
    }
    _authenticationStatusSubject.add(status);
  }

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      await _initPca();
      if (Platform.isIOS) {
        await _initWebParams();
      }
      await loadAccounts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _initPca() async {
    try {
      _pca = await MSALPublicClientApplication.createPublicClientApplication(
          config);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _initWebParams() async {
    try {
      await _pca.initWebViewParams(webParams ?? MSALWebviewParameters());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadAccounts() async {
    try {
      final defaultUserId = _prefs.getString(_kDefaultUser);
      final accounts = await _pca.loadAccounts();
      if (accounts != null && accounts.isNotEmpty) {
        _accountSubject.add(accounts);
        _currentAccount = accounts.firstWhere(
            (element) => element.identifier == defaultUserId,
            orElse: () => accounts.first);
        _updateStatus(AuthenticationStatus.authenticated);
      } else {
        _updateStatus(AuthenticationStatus.unauthenticated);
        _accountSubject.add(null);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setCurrentAccount(MSALAccount account) async {
    _currentAccount = account;
    await _prefs.setString(_kDefaultUser, account.identifier);
  }

  Future<MSALResult?> acquireToken(
      {MSALInteractiveTokenParameters? params}) async {
    try {
      return await _pca.acquireToken(params ?? _defaultInteractiveParams);
    } catch (e) {
      rethrow;
    }
  }

  Future<MSALResult?> acquireTokenSilently(
      {MSALSilentTokenParameters? params}) async {
    try {
      return await _pca.acquireTokenSilent(
          params ?? _defaultSilentParams, _currentAccount);
    } catch (e) {
      rethrow;
    } finally {
      await loadAccounts();
    }
  }

  Future login({
    Uri? authorityOverride,
  }) async {
    MSALInteractiveTokenParameters? params;
    try {
      // if override set, reinit with new authority
      if (authorityOverride != null && authorityOverride != config.authority) {
        params =
            _defaultInteractiveParams.copyWith(authority: authorityOverride);
      }

      print("Logging in");
      _updateStatus(AuthenticationStatus.authenticating);
      await _pca.acquireToken(params ?? _defaultInteractiveParams);
      _updateStatus(AuthenticationStatus.authenticated);
      await loadAccounts();
    } catch (e) {
      _updateStatus(AuthenticationStatus.failed);
      rethrow;
    }
  }

  Future logout(
      {MSALSignoutParameters? signoutParameters, MSALAccount? account}) async {
    try {
      if (account != null || _currentAccount != null) {
        await _pca.logout(signoutParameters ?? _defaultSignoutParameters,
            account ?? _currentAccount!);
        await loadAccounts();
      } else {
        throw Exception("No account to sign out");
      }
    } finally {
      _updateStatus(AuthenticationStatus.unauthenticated);
    }
  }

  void dispose() {
    _accountSubject.close();
  }
}
