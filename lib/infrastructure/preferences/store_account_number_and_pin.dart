import 'package:shared_preferences/shared_preferences.dart';

class UserDataStorage {
  static const String emailKey = 'email'; // Add email key
  static const String passwordKey = 'password'; // Add password key

  // Save user's email and password to shared preferences
  static Future<void> saveUserEmailAndPassword(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(emailKey, email);
    await prefs.setString(passwordKey, password);
  }

  // Retrieve user's email and password from shared preferences
  static Future<Map<String, String>> getUserEmailAndPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(emailKey);
    final password = prefs.getString(passwordKey);

    return {
      emailKey: email ?? '',
      passwordKey: password ?? '',
    };
  }
}
