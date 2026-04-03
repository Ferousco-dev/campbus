import 'package:cloud_firestore/cloud_firestore.dart';

class WalletService {
  WalletService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> recordTopUp({
    required String userId,
    required double amount,
    required String reference,
    required String methodLabel,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    final txRef = userRef.collection('transactions').doc();
    final now = Timestamp.now();

    await _firestore.runTransaction((transaction) async {
      final userSnap = await transaction.get(userRef);
      final currentBalance =
          (userSnap.data()?['walletBalance'] as num?)?.toDouble() ?? 0;

      if (!userSnap.exists) {
        transaction.set(userRef, {
          'walletBalance': amount,
          'totalTransactions': 1,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        transaction.update(userRef, {
          'walletBalance': currentBalance + amount,
          'totalTransactions': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      transaction.set(txRef, {
        'title': 'Wallet Top-up',
        'subtitle': 'Via Paystack · $methodLabel',
        'amount': amount,
        'type': 'credit',
        'category': 'topup',
        'date': now,
        'receiptStatus': 'available',
        'reference': reference,
      });
    });
  }
}
