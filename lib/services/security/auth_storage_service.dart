import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/utils/logger.dart';

/// Abstraction for secure platform token storage.
abstract class AuthStorageService {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();

  Future<void> saveRememberedUser(String emailOrPhone);
  Future<String?> getRememberedUser();
  Future<void> clearRememberedUser();

  Future<void> clearSession();
}

/// Secure token storage implementation using [FlutterSecureStorage].
/// Provides encrypted, platform-level secure storage for auth tokens.
class AuthStorageServiceImpl implements AuthStorageService {
  final FlutterSecureStorage _storage;

  static const String _keyAuthToken = 'relycare_auth_jwt_token';
  static const String _keyRememberedUser = 'relycare_remembered_identifier';

  AuthStorageServiceImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _keyAuthToken, value: token);
      AppLogger.info('Saved JWT access token in secure storage', 'AuthStorageService');
    } catch (e, stack) {
      AppLogger.error('Failed to save JWT token in secure storage', e, stack, 'AuthStorageService');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _keyAuthToken);
    } catch (e, stack) {
      AppLogger.error('Failed to read JWT token from secure storage', e, stack, 'AuthStorageService');
      return null;
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _keyAuthToken);
      AppLogger.info('Deleted JWT access token from secure storage', 'AuthStorageService');
    } catch (e, stack) {
      AppLogger.error('Failed to delete JWT token from secure storage', e, stack, 'AuthStorageService');
    }
  }

  @override
  Future<void> saveRememberedUser(String emailOrPhone) async {
    try {
      await _storage.write(key: _keyRememberedUser, value: emailOrPhone);
    } catch (e, stack) {
      AppLogger.error('Failed to save remembered identifier', e, stack, 'AuthStorageService');
    }
  }

  @override
  Future<String?> getRememberedUser() async {
    try {
      return await _storage.read(key: _keyRememberedUser);
    } catch (e, stack) {
      AppLogger.error('Failed to read remembered identifier', e, stack, 'AuthStorageService');
      return null;
    }
  }

  @override
  Future<void> clearRememberedUser() async {
    try {
      await _storage.delete(key: _keyRememberedUser);
    } catch (e, stack) {
      AppLogger.error('Failed to clear remembered identifier', e, stack, 'AuthStorageService');
    }
  }

  @override
  Future<void> clearSession() async {
    await deleteToken();
  }
}
