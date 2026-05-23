import 'dart:math';
import 'package:dio/dio.dart';
import 'package:livetvapp_flutter/core/security/hmac_signer.dart';
// আপনার AesCrypto ফাইলের সঠিক পাথ অনুযায়ী এটি ইম্পোর্ট করুন
// import 'package:livetvapp_flutter/core/security/aes_crypto.dart'; 

class SecureInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final nonce = _generateNonce(); // random 8-char string
    
    // HMAC সিগনেচার তৈরি
    final signature = HmacSigner.generateSignature(
      method: options.method,
      endpoint: options.path,
      timestamp: timestamp,
      nonce: nonce,
    );

    // প্রতিটি রিকোয়েস্টে এই হেডারগুলো স্বয়ংক্রিয়ভাবে যুক্ত হবে
    options.headers.addAll({
      'X-Timestamp': timestamp,
      'X-Nonce': nonce,
      'X-Signature': signature,
    });
    
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // সার্ভার থেকে আসা encrypted payload সেফলি ডিক্রিপ্ট করা
    try {
      if (response.data != null && response.data is Map && response.data['data'] != null) {
        final encryptedBody = response.data['data'];
        
        if (encryptedBody is String) {
          // ডেটা ডিক্রিপ্ট করে আবার রেসপন্সে অ্যাসাইন করা
          // response.data['data'] = AesCrypto.decrypt(encryptedBody);
        }
      }
    } catch (e) {
      // ডিক্রিপশনে কোনো এরর হলে অ্যাপ ক্র্যাশ না করে এরর লগ করবে
      print("Decryption Error: $e");
    }
    
    handler.next(response);
  }

  // নিরাপদ ও র্যান্ডম ৮ অক্ষরের নন্স (Nonce) জেনারেটর
  String _generateNonce() {
    final random = Random();
    return List.generate(8, (_) => random.nextInt(36).toRadixString(36)).join();
  }
}
