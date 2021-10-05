import 'package:flutter/foundation.dart';

class BuildInfo {
  static bool isRelease() {
    return kReleaseMode;
  }

  static bool isDebug() {
    return !isRelease();
  }
}
