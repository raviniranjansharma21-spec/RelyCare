import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:relycare/services/security/auth_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthStorageService Tests', () {
    late AuthStorageService storageService;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      storageService = AuthStorageServiceImpl(storage: const FlutterSecureStorage());
    });

    test('Save and retrieve JWT token', () async {
      await storageService.saveToken('test_jwt_token_123');
      final token = await storageService.getToken();
      assert(token == 'test_jwt_token_123');
    });

    test('Delete token clears stored JWT', () async {
      await storageService.saveToken('test_jwt_token_456');
      await storageService.deleteToken();
      final token = await storageService.getToken();
      assert(token == null);
    });

    test('Save and retrieve remembered user identifier', () async {
      await storageService.saveRememberedUser('user@example.com');
      final user = await storageService.getRememberedUser();
      assert(user == 'user@example.com');
    });

    test('Clear session removes JWT token', () async {
      await storageService.saveToken('active_token');
      await storageService.clearSession();
      final token = await storageService.getToken();
      assert(token == null);
    });
  });
}
