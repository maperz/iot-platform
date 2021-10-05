import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformInfo {
  static bool isMobile() {
    return Platform.isIOS || Platform.isAndroid;
  }

  static bool isDesktopOS() {
    return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
  }

  static bool isWeb() {
    return kIsWeb;
  }
}
