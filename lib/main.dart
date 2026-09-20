// TODO: Download Inter fonts (Regular, Medium, SemiBold, Bold) from fonts.google.com and place them in assets/fonts/. Then this app will work fully offline.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/app.dart';
import 'core/utils/logger.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Disable online fetching so fonts are served from bundled offline assets
  GoogleFonts.config.allowRuntimeFetching = false;

  AppLogger.info('Initializing RelyCare application...', 'Main');

  // TODO: Initialize local SQLite database (LocalStorageService.init())
  // TODO: Register Providers / Dependency Injection container

  runApp(const RelyCareApp());
}
