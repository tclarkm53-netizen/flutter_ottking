import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HmacSigner {
  /// `.env` ফাইল থেকে সিক্রেট কি রিড করার মেথড
  static String get _secretKey {
    // যদি কোনো কারণে .env লোড না হয়, তাহলে অ্যাপ ক্র্যাশ করা থেকে বাঁচতে একটি ফলব্যাক খালি স্ট্রিং রাখা হয়েছে
    return dotenv.env['HMAC_SECRET_KEY'] ?? '';
  }

  /// প্রতিটি API রিকোয়েস্টের জন্য HMAC সিগনেচার তৈরি করে।
  /// payload = method + endpoint + timestamp + nonce
  static String generateSignature({
    required String method,
    required String endpoint,
    required String timestamp,
    required String nonce,
  }) {
    final message = '$method:$endpoint:$timestamp:$nonce';
    final key = utf8.encode(_secretKey);
    final bytes = utf8.encode(message);
    final hmac = Hmac(sha256, key);
    return hmac.convert(bytes).toString();
  }
}
