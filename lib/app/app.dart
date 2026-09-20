import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import 'routes.dart';
import 'app_dependencies.dart';

/// Root application widget for RelyCare.
class RelyCareApp extends StatelessWidget {
  final AppDependencies? dependencies;

  const RelyCareApp({super.key, this.dependencies});

  @override
  Widget build(BuildContext context) {
    final activeDependencies = dependencies ?? AppDependencies();

    return RelyCareScope(
      dependencies: activeDependencies,
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
