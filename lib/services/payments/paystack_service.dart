import 'dart:math';

class PaystackChargeResult {
  final bool success;
  final String reference;
  final String message;
  final bool isDemo;

  const PaystackChargeResult({
    required this.success,
    required this.reference,
    required this.message,
    this.isDemo = false,
  });
}

class PaystackService {
  PaystackService._();

  static const String publicKey =
      String.fromEnvironment('PAYSTACK_PUBLIC_KEY', defaultValue: '');
  static const bool enableDemoMode =
      bool.fromEnvironment('PAYSTACK_DEMO', defaultValue: true);

  static bool get isConfigured => publicKey.isNotEmpty;

  static String generateReference() {
    final millis = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(900000) + 100000;
    return 'CW-$millis-$rand';
  }

  static Future<PaystackChargeResult> charge({
    required String email,
    required double amount,
    String? reference,
  }) async {
    final ref = reference ?? generateReference();

    if (!isConfigured) {
      if (!enableDemoMode) {
        return PaystackChargeResult(
          success: false,
          reference: ref,
          message: 'Paystack public key not configured',
        );
      }
      await Future.delayed(const Duration(seconds: 2));
      return PaystackChargeResult(
        success: true,
        reference: ref,
        message: 'Paystack demo mode',
        isDemo: true,
      );
    }

    return PaystackChargeResult(
      success: false,
      reference: ref,
      message: 'Paystack SDK not configured',
    );
  }
}
