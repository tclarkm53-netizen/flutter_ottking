// lib/core/security/hmac_signer.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

class HmacSigner {
  // ⚠️ প্রোডাকশনে এই key flutter_dotenv বা native obfuscation থেকে নাও
  static const _secretKey = 'YOUR_SECRET_KEY_HERE';

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
