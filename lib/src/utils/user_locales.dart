import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';

class LocaleInfo {
  static Locale getCurrentLocale() {
    return WidgetsBinding.instance.platformDispatcher.locale;
  }

  static String getCurrentCountry() {
    Locale locale = getCurrentLocale();
    return locale.countryCode ?? 'Unknown';
  }

  static String getCurrentLanguage() {
    Locale locale = getCurrentLocale();
    return locale.languageCode;
  }

  static String getCurrentTimezone() {
    DateTime now = DateTime.now();
    String timezone = now.timeZoneName;
    return timezone;
  }

  static String getPlatformName() {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isLinux) {
      return 'linux';
    } else {
      return 'unknown';
    }
  }

  static int getTimeZoneOffsetInSeconds() {
    DateTime now = DateTime.now();
    Duration offset = now.timeZoneOffset;
    return offset.inSeconds;
  }
}
