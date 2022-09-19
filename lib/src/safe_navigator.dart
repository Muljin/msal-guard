import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class SafeNavigator extends Navigator {
  const SafeNavigator({
    super.key,
    super.pages = const <Page<dynamic>>[],
    super.onPopPage,
    super.initialRoute,
    super.onGenerateInitialRoutes = Navigator.defaultGenerateInitialRoutes,
    super.onGenerateRoute,
    super.onUnknownRoute,
    super.transitionDelegate = const DefaultTransitionDelegate<dynamic>(),
    super.reportsRouteUpdateToEngine = false,
    super.observers = const <NavigatorObserver>[],
    super.requestFocus = true,
    super.restorationScopeId,
  });

  @override
  NavigatorState createState() => _SafeNavigatorState();
}

class _SafeNavigatorState extends NavigatorState {
  @override
  Future<T?> pushNamed<T extends Object?>(String routeName,
      {Object? arguments}) {
    return super.pushNamed(routeName, arguments: arguments);
  }
}
