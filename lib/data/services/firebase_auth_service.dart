import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  static final FirebaseAuthService instance = FirebaseAuthService._internal();

  static const String serverClientId =
      '472022657503-rrpdp12ussod2875eiva4vs74iq5p4oi.apps.googleusercontent.com';

  FirebaseAuthService._internal() {
    if (!kIsWeb) {
      GoogleSignIn.instance.initialize(
        serverClientId: serverClientId,
      );
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Google Sign-In supporting both Mobile and Web
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider authProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(authProvider);
      } else {
        await GoogleSignIn.instance.initialize(
          serverClientId: serverClientId,
        );
        final googleUser =
            await GoogleSignIn.instance.authenticate();
        final googleAuth = googleUser.authentication;
        if (googleAuth.idToken == null) {
          throw Exception('Google Sign-In failed: No ID token returned.');
        }
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    }
  }

  /// Phone Authentication - Trigger verification code SMS
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(String verificationId) onCodeAutoRetrievalTimeout,
    int? resendToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      forceResendingToken: resendToken,
      timeout: const Duration(seconds: 60),
    );
  }

  /// Verify SMS OTP code and Sign In
  Future<UserCredential> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  /// Sync user profile with Firestore database
  Future<void> syncUserProfileToFirestore(
    User user, {
    String? name,
    String? phone,
    String? city,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
            'uid': user.uid,
            'email': user.email ?? '',
            'name': name ?? user.displayName ?? 'User',
            'phone': phone ?? user.phoneNumber ?? '',
            'city': city ?? 'Tenkasi',
            'photoUrl': user.photoURL ?? '',
            'lastLogin': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Firestore sync note: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await GoogleSignIn.instance.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }
}
