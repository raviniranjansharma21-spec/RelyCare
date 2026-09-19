import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/utils/logger.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.info('Initializing RelyCare application...', 'Main');

  // TODO: Initialize local SQLite database (LocalStorageService.init())
  // TODO: Register Providers / Dependency Injection container

  runApp(const RelyCareApp());
}
