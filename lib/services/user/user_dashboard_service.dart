import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/transaction_model.dart';

class UserDashboardService {
  UserDashboardService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<DocumentSnapshot<Map<String, dynamic>>> userStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  static Stream<List<TransactionModel>> recentTransactionsStream(
    String uid, {
    int limit = 20,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  TransactionModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }
}
