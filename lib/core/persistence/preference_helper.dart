import 'package:mobile_web/core/constants/constants.dart';
import 'package:mobile_web/core/persistence/preferences.dart';

class PreferenceHelper {
  static const url = 'url';
  static const themeKey = "theme_key";

  static Future<void> setUrl(String newUrl) async {
    await Preferences.setString(url, newUrl);
  }

  static Future<String> getUrl() {
    return Preferences.getString(url, initialUrl);
  }

  setTheme(bool value) async {
     await Preferences.setBool(themeKey, value);
  }

  getTheme() async {
    return Preferences.getBool(themeKey, false);
  }

  static Future<void> clearPreference() async {
    await Preferences.remove(url);
    await Preferences.remove(themeKey);
  }
}
