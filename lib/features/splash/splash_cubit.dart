import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:livetvapp_flutter/core/platform/platform_detector.dart';

// আপনার প্রোজেক্টের সঠিক পাথ অনুযায়ী স্টেট ফাইল ইম্পোর্ট করুন
// import 'splash_state.dart'; 

class SplashCubit extends Cubit<SplashState> {
  final SharedPreferences _prefs;
  
  SplashCubit(this._prefs) : super(SplashInitial());

  Future<void> initialize() async {
    // ১. সিকিউরিটি চেক (Root / Jailbreak Detection)
    bool isSecure = await _checkDeviceSecurity();
    if (!isSecure) {
      emit(SplashDeviceCompromised());
      return; // ডিভাইস নিরাপদ না হলে এখানেই কোড এক্সিকিউশন থামিয়ে দেবে
    }

    // ২. স্প্ল্যাশ স্ক্রিনের মিনিমাম হোল্ড টাইম (যেমন ২ বা ৩ সেকেন্ড)
    await Future.delayed(const Duration(seconds: 2));

    // ৩. প্ল্যাটফর্ম এবং ইউজার প্রেফারেন্স চেক
    final isTv = PlatformDetector.isTV;
    
    // boot-to-player শুধুমাত্র TV-তে এবং সেটিং চালু থাকলে কাজ করে
    final bootToPlayer = isTv && (_prefs.getBool('boot_to_player') ?? false);

    if (bootToPlayer) {
      // টিভি চালু হলে সরাসরি লাস্ট চ্যানেল বা ডিফল্ট চ্যানেল প্লেয়ারে নিয়ে যাবে
      emit(SplashBootToPlayer(defaultChannelId: 'ch_001'));
    } else {
      // মোবাইলের জন্য বা টিভিতে সেটিং অফ থাকলে হোম স্ক্রিনে যাবে
      emit(SplashGoHome());
    }
  }

  /// ডিভাইস নিরাপদ কি না তা যাচাই করার প্রাইভেট মেথড
  Future<bool> _checkDeviceSecurity() async {
    try {
      // ডিভাইসটি রুট বা জেলব্রেক করা কিনা তা চেক করবে
      bool isJailbrokenOrRooted = await FlutterJailbreakDetection.jailbroken;
      
      // যদি রুট করা থাকে (true), তবে এটি false (নিরাপদ নয়) রিটার্ন করবে
      return !isJailbrokenOrRooted;
    } on PlatformException {
      // কোনো কারণে নেটিভ চেক ফেল করলে সেফটির জন্য অ্যাপ ব্লক করা ভালো (false রিটার্ন)
      return false; 
    } catch (_) {
      return false;
    }
  }
}
