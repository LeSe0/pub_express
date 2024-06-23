import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveNotificationToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('px_ic_id', token);
}

Future<String?> getNotificationToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('px_ic_id');
}
