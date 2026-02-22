import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../modules/auth/auth_models.dart';

class AuthRepository {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveUser(User user) async {
    final prefs = await _preferences;
    await prefs.setString(AppConstants.userDataKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final prefs = await _preferences;
    final userJson = prefs.getString(AppConstants.userDataKey);
    if (userJson == null) return null;

    try {
      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await _preferences;
    await prefs.setString(AppConstants.authTokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await _preferences;
    return prefs.getString(AppConstants.authTokenKey);
  }

  Future<void> clearUser() async {
    await clearAuthData();
  }

  Future<void> clearAuthData() async {
    final prefs = await _preferences;
    await prefs.remove(AppConstants.userDataKey);
    await prefs.remove(AppConstants.authTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
