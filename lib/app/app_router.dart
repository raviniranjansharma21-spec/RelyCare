import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/login/login_screen.dart';
import '../screens/phc_dashboard/phc_dashboard_screen.dart';
import '../screens/hospital_dashboard/hospital_dashboard_screen.dart';
import '../screens/create_referral/create_referral_screen.dart';
import '../screens/identity_matching/identity_matching_screen.dart';
import '../screens/referral_details/referral_details_screen.dart';

/// Centralized GoRouter navigation configuration for RelyCare.
class AppRouter {
  static const String login = '/login';
  static const String phcDashboard = '/phc-dashboard';
  static const String hospitalDashboard = '/hospital-dashboard';
  static const String dashboard = '/dashboard';
  static const String createReferral = '/create-referral';
  static const String identityMatching = '/identity-matching';
  static const String referralDetails = '/referral-details';

  static final GoRouter router = GoRouter(
    initialLocation: login,
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
    ],
  );
}
