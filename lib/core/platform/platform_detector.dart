import 'dart:io';
import 'package:flutter/services.dart';

class PlatformDetector {
  static const MethodChannel _channel = MethodChannel('app/platform_info');
  static bool _isTv = false;

  /// অ্যাপ স্টার্টে (main.dart-এ) একবার কল করো
  static Future<void> initialize() async {
    if (!Platform.isAndroid) { 
      _isTv = false; 
      return; 
    }
    
    try {
      // Android-এ UiModeManager দিয়ে TV mode চেক করা হয় নেটিভ কোডে
      _isTv = await _channel.invokeMethod<bool>('isAndroidTV') ?? false;
    } catch (e) {
      // এরর লগ করতে পারেন ডেভেলপমেন্টের সুবিধার্থে
      print("PlatformDetector Error: $e");
      _isTv = false;
    }
  }

  static bool get isTV => _isTv;
  static bool get isMobile => !_isTv;
}
