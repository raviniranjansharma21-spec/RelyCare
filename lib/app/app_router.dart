import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/login/login_screen.dart';
import '../screens/phc_dashboard/phc_dashboard_screen.dart';
import '../screens/hospital_dashboard/hospital_dashboard_screen.dart';
import '../screens/create_referral/create_referral_screen.dart';
import '../screens/identity_matching/identity_matching_screen.dart';
import '../screens/referral_details/referral_details_screen.dart';
import '../screens/user_tracking/user_tracking_screen.dart';
import '../providers/auth_provider.dart';

/// Centralized GoRouter navigation configuration for RelyCare.
class AppRouter {
  static const String login = '/login';
  static const String phcDashboard = '/phc-dashboard';
  static const String hospitalDashboard = '/hospital-dashboard';
  static const String dashboard = '/dashboard';
  static const String createReferral = '/create-referral';
  static const String identityMatching = '/identity-matching';
  static const String referralDetails = '/referral-details';
  static const String userTracking = '/user-tracking';

  /// Routes that do NOT require authentication.
  static const _publicRoutes = {login, userTracking};

  /// Creates a [GoRouter] that re-evaluates the redirect whenever
  /// [authProvider] calls [notifyListeners].
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: login,
      refreshListenable: authProvider,
      redirect: (BuildContext context, GoRouterState state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isPublic = _publicRoutes.contains(state.matchedLocation);

        // Unauthenticated user trying to reach a protected route → redirect to login.
        if (!isAuthenticated && !isPublic) {
          return login;
        }

        // Authenticated user landing on the login page → send to their dashboard.
        if (isAuthenticated && state.matchedLocation == login) {
          switch (authProvider.selectedRole) {
            case 'Hospital Staff':
              return hospitalDashboard;
            case 'Patient':
              return userTracking;
            default:
              return phcDashboard;
          }
        }

        // No redirect needed.
        return null;
      },
      routes: [
        GoRoute(
          path: login,
          name: 'login',
          builder: (BuildContext context, GoRouterState state) {
            return const LoginScreen();
          },
        ),
        GoRoute(
          path: phcDashboard,
          name: 'phcDashboard',
          builder: (BuildContext context, GoRouterState state) {
            return const PHCDashboardScreen();
          },
        ),
        GoRoute(
          path: hospitalDashboard,
          name: 'hospitalDashboard',
          builder: (BuildContext context, GoRouterState state) {
            return const HospitalDashboardScreen();
          },
        ),
        GoRoute(
          path: dashboard,
          name: 'dashboard',
          builder: (BuildContext context, GoRouterState state) {
            return const PHCDashboardScreen();
          },
        ),
        GoRoute(
          path: createReferral,
          name: 'createReferral',
          builder: (BuildContext context, GoRouterState state) {
            return const CreateReferralScreen();
          },
        ),
        GoRoute(
          path: identityMatching,
          name: 'identityMatching',
          builder: (BuildContext context, GoRouterState state) {
            return const IdentityMatchingScreen();
          },
        ),
        GoRoute(
          path: referralDetails,
          name: 'referralDetails',
          builder: (BuildContext context, GoRouterState state) {
            return const ReferralDetailsScreen();
          },
        ),
        GoRoute(
          path: userTracking,
          name: 'userTracking',
          builder: (BuildContext context, GoRouterState state) {
            return const UserTrackingScreen();
          },
        ),
      ],
    );
  }
}
