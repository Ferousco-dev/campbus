import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/auth/registration_payload.dart';
import 'pin_service.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;

  static Future<UserCredential> registerAccount({
    required RegistrationPayload payload,
    required String pin,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: payload.email,
      password: pin,
    );

    await credential.user?.updateDisplayName(payload.fullName);

    final userId = credential.user?.uid;
    if (userId != null) {
      final nickname = payload.fullName.trim().split(RegExp(r'\s+')).first;
      await _firestore.collection('users').doc(userId).set({
        ...payload.toFirestore(),
        'studentId': payload.matricNumber,
        'nickname': nickname,
        'role': 'user',
        'walletBalance': 0.0,
        'totalCredits': 0.0,
        'totalDebits': 0.0,
        'totalTransactions': 0,
        'totalSpent': 0.0,
        'cardStatus': 'inactive',
        'faculty': '',
        'department': '',
        'level': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'pinUpdatedAt': FieldValue.serverTimestamp(),
        'isVerified': false,
        'isEmailVerified': credential.user?.emailVerified ?? false,
        'tier': 'tier1',
      }, SetOptions(merge: true));
    }

    await PinService.cacheEmail(payload.email);
    await PinService.cachePinHash(pin);

    return credential;
  }

  static Future<UserCredential> signInWithPin({
    required String email,
    required String pin,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: pin,
    );

    await PinService.cacheEmail(email);
    await PinService.cachePinHash(pin);

    return credential;
  }

  static Future<void> updatePin({required String pin}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user.');
    }

    await user.updatePassword(pin);
    await _firestore.collection('users').doc(user.uid).set({
      'updatedAt': FieldValue.serverTimestamp(),
      'pinUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await PinService.cachePinHash(pin);
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    await PinService.clearSession();
  }
}
