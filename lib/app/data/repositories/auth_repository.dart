import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _createUserData(userCredential.user!, firstName, lastName);
      }
    } on FirebaseAuthException catch (e) {
      // PERBAIKAN: Lempar kembali exception asli agar controller bisa
      // menangani e.code ('email-already-in-use', 'weak-password', dll)
      rethrow;
    }
  }

  Future<void> _createUserData(User user, String firstName, String lastName) async {
    final userDocRef = _firestore.collection('users').doc(user.uid);
    await userDocRef.set({
      'firstName': firstName,
      'lastName': lastName,
      'email': user.email,
    });
  }

  // PERBAIKAN: Ubah return type ke UserCredential
  Future<UserCredential> signIn({required String email, required String password}) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Hapus semua logika pengecekan verifikasi dari sini.
      // Biarkan controller yang menanganinya.

      return userCredential;

    } on FirebaseAuthException catch (e) {
      // PERBAIKAN: Lempar kembali exception asli agar controller bisa
      // menangani e.code ('user-not-found', 'wrong-password', dll)
      rethrow;
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // PERBAIKAN: Lempar kembali exception asli
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      // PERBAIKAN: Lempar kembali exception asli
      rethrow;
    }
  }

}