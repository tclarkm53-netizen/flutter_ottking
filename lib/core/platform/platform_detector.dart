// lib/core/platform/platform_detector.dart
import 'dart:io';
import 'package:flutter/services.dart';

class PlatformDetector {
  static bool _isTv = false;

  /// অ্যাপ স্টার্টে একবার কল করো
  static Future<void> initialize() async {
    if (!Platform.isAndroid) { _isTv = false; return; }
    try {
      const channel = MethodChannel('app/platform_info');
      // Android-এ UiModeManager দিয়ে TV mode চেক করা হয়
      _isTv = await channel.invokeMethod('isAndroidTV') ?? false;
    } catch (_) {
      _isTv = false;
    }
  }

  static bool get isTV => _isTv;
  static bool get isMobile => !_isTv;
}
