import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/create_referral/create_referral_screen.dart';
import '../screens/referrals/referrals_screen.dart';
import '../screens/referrals/referral_details_screen.dart';
import '../screens/identity_matching/identity_matching_screen.dart';
import '../screens/sync/sync_status_screen.dart';
import '../screens/profile/profile_screen.dart';

/// Centralized route definitions and generator for RelyCare.
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String createReferral = '/create-referral';
  static const String referrals = '/referrals';
  static const String referralDetails = '/referral-details';
  static const String identityMatching = '/identity-matching';
  static const String syncStatus = '/sync-status';
  static const String profile = '/profile';

  /// Map of routes to widget builders
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        onboarding: (context) => const OnboardingScreen(),
        login: (context) => const LoginScreen(),
        dashboard: (context) => const DashboardScreen(),
        createReferral: (context) => const CreateReferralScreen(),
        referrals: (context) => const ReferralsScreen(),
        referralDetails: (context) => const ReferralDetailsScreen(),
        identityMatching: (context) => const IdentityMatchingScreen(),
        syncStatus: (context) => const SyncStatusScreen(),
        profile: (context) => const ProfileScreen(),
      };
}
