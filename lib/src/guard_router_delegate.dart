import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:msal_flutter/msal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../msal_guard.dart';
import 'authentication_interceptor.dart';
import 'client/authenticated_http.dart';
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

  final String? apiBaseUrl;

  List<SingleChildWidget>? providers;

  final Function(GlobalKey<NavigatorState>)? onKeyChange;
  GuardRouterDelegate({
    required this.initialPublicRoute,
    required this.initialProtectedRoute,
    required this.onPublicRoute,
    required this.onProtectedRoute,
    required this.loadingWidget,
    required MSALPublicClientApplicationConfig config,
    required List<String> defaultScopes,
    MSALWebviewParameters? webParams,
    AuthenticationService? authenticationService,
    this.onKeyChange,
    this.apiBaseUrl,
    this.navigatorObservers,
    this.onUnknownRoute,
    this.providers,
  }) : this._authenticationService = authenticationService ??
            AuthenticationService(
                config: config,
                defaultScopes: defaultScopes,
                webParams: webParams) {
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
              create: (_) => AuthenticatedHttp(interceptors: [
                    AuthenticationInterceptor(_authenticationService)
                  ], baseUrl: apiBaseUrl)),
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
