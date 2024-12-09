import 'package:algorhymns/data/models/auth/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static Future<void> saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('fullName', user.fullName ?? '');
    prefs.setString('email', user.email ?? '');
    prefs.setString('imageURL', user.imageURL ?? '');
  }

  static Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString('fullName');
    final email = prefs.getString('email');
    final imageURL = prefs.getString('imageURL');

    if (email == null) return null;

    return UserModel(
      fullName: fullName,
      email: email,
      imageURL: imageURL,
    );
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}