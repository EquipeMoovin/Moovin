import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<bool> isLoggedIn() async {
    String? token = await _secureStorage.read(key: 'access_token');
    return token != null;
  }

  Future<String?> getUserType() async {
    return await _secureStorage.read(key: 'user_type');
  }

  Future<bool> isOwner() async {
    String? userType = await getUserType();
    return userType == 'Proprietario';
  }

  Future<bool> isTenant() async {
    String? userType = await getUserType();
    return userType == 'Inquilino';
  }

  Future<bool> hasRole(String role) async {
    String? userType = await getUserType();
    return userType == role;
  }
}
