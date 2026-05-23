// lib/core/network/secure_interceptor.dart
class SecureInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final nonce = _generateNonce();  // random 8-char string
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
    // সার্ভার থেকে আসা encrypted payload মেমরিতে decrypt করো
    final encryptedBody = response.data['data'] as String;
    response.data['data'] = AesCrypto.decrypt(encryptedBody);
    handler.next(response);
  }

  String _generateNonce() =>
    List.generate(8, (_) => Random().nextInt(36).toRadixString(36)).join();
}
