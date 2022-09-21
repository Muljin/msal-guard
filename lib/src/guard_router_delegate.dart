import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../msal_guard.dart';
import 'safe_navigator.dart';

class GuardRouterDelegate<T> extends RouterDelegate<T>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<T> {
  final RouteFactory? onPublicRoute;
  final RouteFactory? onProtectedRoute;
  final String? initialPublicRoute;
  final String? initialProtectedRoute;
  final List<NavigatorObserver>? navigatorObservers;

  final RouteFactory? onUnknownRoute;

  final Widget loadingWidget;

  final String clientId;
  final String? authority;
  final List<String>? additionalAuthorities;
  final String? redirectUri;
  final List<String> scopes;

  final String? apiBaseUrl;

  List<SingleChildWidget>? providers;

  /// this is only used in ios it won't affect android configuration
  /// for more info go to https://docs.microsoft.com/en-us/azure/active-directory/develop/single-sign-on-macos-ios#silent-sso-between-apps
  final String? keychain;

  /// privateSession is set to true to request that the browser doesn’t share cookies or other browsing data between the authentication session and the user’s normal browser session. Whether the request is honored depends on the user’s default web browser. Safari always honors the request.
  /// The value of this property is false by default.
  final bool? privateSession;

  //redirect uri overrides
  final String? androidRedirectUri;
  final String? iosRedirectUri;
  final Function(GlobalKey<NavigatorState>)? onKeyChange;
  GuardRouterDelegate({
    required this.initialPublicRoute,
    required this.initialProtectedRoute,
    required this.onPublicRoute,
    required this.onProtectedRoute,
    required this.loadingWidget,
    required this.clientId,
    required this.scopes,
    this.onKeyChange,
    this.authority,
    this.additionalAuthorities,
    this.redirectUri,
    this.androidRedirectUri,
    this.iosRedirectUri,
    this.keychain,
    this.privateSession,
    this.apiBaseUrl,
    this.navigatorObservers,
    this.onUnknownRoute,
    this.providers,
    AuthenticationService? authenticationService,
  }) {
    _authenticationService = authenticationService ??
        AuthenticationService(
            clientId: this.clientId,
            defaultScopes: scopes,
            defaultAuthority: this.authority,
            redirectUri: this.redirectUri,
            keychain: this.keychain,
            iosRedirectUri: this.iosRedirectUri,
            privateSession: privateSession,
            androidRedirectUri: this.androidRedirectUri);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print("Initialising auth");
      _authenticationService.init();
    });
  }

  late AuthenticationService _authenticationService;
  late GlobalKey<NavigatorState>? navKey;

  static const _loadingNavKey = GlobalObjectKey<NavigatorState>('loading');
  static const _protectedNavKey = GlobalObjectKey<NavigatorState>('protected');
  static const _publicNavKey = GlobalObjectKey<NavigatorState>('public');

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<AuthenticationService>(
              create: (_) => _authenticationService),
          Provider<AuthenticatedHttp>(
              create: (_) => AuthenticatedHttp(_authenticationService,
                  baseUrl: apiBaseUrl)),
          ...?providers
        ],
        builder: (context, wiget) => StreamBuilder<AuthenticationStatus>(
            stream: _authenticationService.authenticationStatus,
            builder: (context, snapshot) {
              return SafeNavigator(
                key: _key(snapshot.data),
                initialRoute: initialRoute(snapshot.data),
                observers: navigatorObservers ?? [],
                onUnknownRoute: onUnknownRoute,
                onGenerateRoute: (settings) => _route(settings, snapshot.data),
              );
            }));
  }

  String? initialRoute(AuthenticationStatus? status) {
    switch (status) {
      case AuthenticationStatus.authenticated:
        return initialPublicRoute;
      case AuthenticationStatus.unauthenticated:
      case AuthenticationStatus.failed:
        return initialPublicRoute;

      default:
        return '/';
    }
  }

  GlobalKey<NavigatorState> _key(AuthenticationStatus? status) {
    switch (status) {
      case AuthenticationStatus.authenticated:
        navKey = _protectedNavKey;
        onKeyChange?.call(navKey!);
        return _protectedNavKey;
      case AuthenticationStatus.unauthenticated:
      case AuthenticationStatus.failed:
        navKey = _publicNavKey;
        onKeyChange?.call(navKey!);
        return _publicNavKey;

      default:
        navKey = _loadingNavKey;
        onKeyChange?.call(navKey!);
        return _loadingNavKey;
    }
  }

  Route<dynamic> _route(RouteSettings settings, AuthenticationStatus? status) {
    switch (status) {
      case AuthenticationStatus.authenticated:
        return onProtectedRoute!(settings)!;
      case AuthenticationStatus.unauthenticated:
      case AuthenticationStatus.failed:
        return onPublicRoute!(settings)!;

      default:
        return CupertinoPageRoute(
          builder: (context) => loadingWidget,
        );
    }
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => navKey;

  @override
  Future<void> setNewRoutePath(configuration) async {
    log(configuration.toString());
  }
}

mixin PopNavigatorRouterDelegateMixin<T> on RouterDelegate<T> {
  GlobalKey<NavigatorState>? get navigatorKey;

  @override
  Future<bool> popRoute() {
    final NavigatorState? navigator = navigatorKey?.currentState;
    if (navigator == null) {
      return SynchronousFuture<bool>(false);
    }
    return navigator.maybePop();
  }
}
