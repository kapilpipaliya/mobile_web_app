import 'package:mobile_web/core/constants/constants.dart';
import 'package:mobile_web/core/persistence/preferences.dart';

class PreferenceHelper {
  static String url = 'url';

  static Future<void> setUrl(String newUrl) async {
    await Preferences.setString(url, newUrl);
  }

  static Future<String> getUrl() {
    return Preferences.getString(url, initialUrl);
  }

  static Future<void> clearPreference() async {
    await Preferences.remove(url);
  }
}
