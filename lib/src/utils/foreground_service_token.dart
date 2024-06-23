import 'package:shared_preferences/shared_preferences.dart';

const String _foregroundServiceTokenKey = 'frg_show_token';

Future<void> saveForegroundServiceToken(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(
    _foregroundServiceTokenKey,
    value,
  );
}

Future<bool?> getForegroundServiceToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_foregroundServiceTokenKey);
}
