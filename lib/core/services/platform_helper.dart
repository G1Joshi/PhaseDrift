import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

abstract final class AppPlatform {
  static bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static bool isTouchDevice(BuildContext context) {
    if (isMobile) return true;
    final size = MediaQuery.sizeOf(context);
    return size.height <= 500.0;
  }
}
