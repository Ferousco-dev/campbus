import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileService {
  UserProfileService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<DocumentSnapshot<Map<String, dynamic>>> userStream(
      String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  static Future<void> updateNickname(String uid, String nickname) async {
    await _firestore.collection('users').doc(uid).set({
      'nickname': nickname,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> updateAddress({
    required String uid,
    required String street,
    required String cityState,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'address': {
        'street': street,
        'cityState': cityState,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
