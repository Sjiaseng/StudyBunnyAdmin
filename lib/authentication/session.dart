import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Session {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  // function to store session in secure storage 
  Future<void> storeSession(String userId, String userEmail) async {
    await _secureStorage.write(key: 'userID', value: userId);
  }
  // obtain used ID function
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: 'userID');
  }
  // clear the session when user logout from system
  Future<void> clearSession() async {
    await _secureStorage.delete(key: 'userID');
  }
}
