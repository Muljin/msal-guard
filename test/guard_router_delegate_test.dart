import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:msal_guard/msal_guard.dart';
import 'package:rxdart/subjects.dart';

import 'guard_router_delegate_test.mocks.dart';
import 'widgets_and_routes.dart';

class AuthenticationServiceTest extends Mock implements AuthenticationService {}

@GenerateMocks([AuthenticationServiceTest])
void main() {
  late MockAuthenticationServiceTest mockAuthService;
  late BehaviorSubject<AuthenticationStatus> authenticationStatusMoch;
  setUpAll(() {
    mockAuthService = MockAuthenticationServiceTest();
    authenticationStatusMoch =
        BehaviorSubject.seeded(AuthenticationStatus.none);
    when(mockAuthService.authenticationStatus).thenAnswer((_) {
      return authenticationStatusMoch.stream;
    });
    when(mockAuthService.init()).thenAnswer((_) async {
      authenticationStatusMoch.add(AuthenticationStatus.ready);
    });

    when(mockAuthService.login()).thenAnswer((_) async {
      authenticationStatusMoch.add(AuthenticationStatus.authenticated);
    });
    when(mockAuthService.logout()).thenAnswer((_) async {
      authenticationStatusMoch.add(AuthenticationStatus.unauthenticated);
    });
  });

  group('test', () {
    testWidgets('should show loading widget', (WidgetTester tester) async {
      final myWidget = MaterialApp.router(
        routerDelegate: GuardRouterDelegate(
            authenticationService: mockAuthService,
            initialPublicRoute: '/',
            initialProtectedRoute: '/',
            onPublicRoute: onPublic,
            onProtectedRoute: onProtected,
            loadingWidget: LoadingWidget(),
            clientId: 'clientId',
            scopes: ['scopes']),
      );

      await tester.pumpWidget(myWidget);
      await tester.pumpAndSettle();

      expect(find.text('Loading'), findsOneWidget);
    });

    testWidgets('should show protected widget', (WidgetTester tester) async {
      final myWidget = MaterialApp.router(
        routerDelegate: GuardRouterDelegate(
            authenticationService: mockAuthService,
            initialPublicRoute: '/',
            initialProtectedRoute: '/',
            onPublicRoute: onPublic,
            onProtectedRoute: onProtected,
            loadingWidget: LoadingWidget(),
            clientId: 'clientId',
            scopes: ['scopes']),
      );
      await tester.pumpWidget(myWidget);
      await mockAuthService.login();
      await tester.pumpAndSettle();
      expect(find.text('Protected'), findsOneWidget);
    });
    testWidgets('should show public widget', (WidgetTester tester) async {
      final myWidget = MaterialApp.router(
        routerDelegate: GuardRouterDelegate(
            authenticationService: mockAuthService,
            initialPublicRoute: '/',
            initialProtectedRoute: '/',
            onPublicRoute: onPublic,
            onProtectedRoute: onProtected,
            loadingWidget: LoadingWidget(),
            clientId: 'clientId',
            scopes: ['scopes']),
      );
      await tester.pumpWidget(myWidget);
      await mockAuthService.logout();
      await tester.pumpAndSettle();
      expect(find.text('Public'), findsOneWidget);
    });
    testWidgets('auth flow test', (WidgetTester tester) async {
      final myWidget = MaterialApp.router(
        routerDelegate: GuardRouterDelegate(
            authenticationService: mockAuthService,
            initialPublicRoute: '/',
            initialProtectedRoute: '/',
            onPublicRoute: onPublic,
            onProtectedRoute: onProtected,
            loadingWidget: LoadingWidget(),
            clientId: 'clientId',
            scopes: ['scopes']),
      );
      // is showing loading view
      await tester.pumpWidget(myWidget);
      expect(find.text('Loading'), findsOneWidget);

      // is showing protected view
      await mockAuthService.login();
      await tester.pumpAndSettle();
      expect(find.text('Protected'), findsOneWidget);
      // is showing public view
      await mockAuthService.logout();
      await tester.pumpAndSettle();
      expect(find.text('Public'), findsOneWidget);
    });
  });

  tearDownAll(
    () {
      authenticationStatusMoch.close();
    },
  );
}
