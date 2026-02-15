import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartkoi/app/data/models/user_model.dart';
import 'package:smartkoi/app/shared/widgets/alert_helper.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State user yang observable
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserDetails();
  }

  /// Mengambil data detail user dari Firestore
  Future<void> fetchUserDetails() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        final docSnapshot = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (docSnapshot.exists) {
          // Asumsi: UserModel.fromMap sudah dibuat sesuai struktur data kamu
          user.value = UserModel.fromMap(firebaseUser.uid, docSnapshot.data()!);
        }
      } catch (e) {
        debugPrint("Error fetching user: $e");
      }
    }
  }

  /// Memperbarui Nama Depan dan Belakang
  Future<void> updateUserName(String firstName, String lastName) async {
    if (isLoading.value) return;

    // 1. Validasi Input
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      CustomAlert.show(AlertType.warning, 'Input Kosong', 'Nama depan dan belakang wajib diisi.');
      return;
    }

    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      isLoading.value = true;
      try {
        // Update di Firestore (Database)
        await _firestore.collection('users').doc(firebaseUser.uid).update({
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
        });

        // Update di Firebase Auth (Display Name)
        await firebaseUser.updateDisplayName('$firstName $lastName');

        // Refresh data lokal agar UI berubah
        await fetchUserDetails();

        Get.back(); // Tutup dialog/bottom sheet
        CustomAlert.show(AlertType.success, 'Sukses', 'Profil berhasil diperbarui.');
      } catch (e) {
        CustomAlert.show(AlertType.error, 'Gagal', 'Gagal memperbarui profil: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  /// Mengganti Password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    if (isLoading.value) return;

    final user = _auth.currentUser;
    final String email = user?.email ?? '';

    if (user == null || email.isEmpty) return;

    // 1. Validasi Input Password
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      CustomAlert.show(AlertType.warning, 'Input Kosong', 'Semua kolom password harus diisi.');
      return;
    }

    if (newPassword.length < 6) {
      CustomAlert.show(AlertType.warning, 'Password Lemah', 'Password baru minimal 6 karakter.');
      return;
    }

    if (currentPassword == newPassword) {
      CustomAlert.show(AlertType.warning, 'Password Sama', 'Password baru tidak boleh sama dengan yang lama.');
      return;
    }

    isLoading.value = true;
    try {
      // Re-autentikasi (Keamanan: Pastikan yang minta ganti password adalah pemilik akun asli)
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Jika re-auth berhasil, baru update password
      await user.updatePassword(newPassword);

      Get.back(); // Tutup dialog
      CustomAlert.show(AlertType.success, 'Sukses', 'Kata sandi berhasil diubah. Silakan login ulang jika diperlukan.');

    } on FirebaseAuthException catch (e) {
      String message = 'Gagal mengubah kata sandi.';

      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Kata sandi saat ini salah. Periksa kembali input Anda.';
      } else if (e.code == 'weak-password') {
        message = 'Kata sandi baru terlalu lemah.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Demi keamanan, silakan Logout dan Login kembali sebelum mengganti password.';
      }

      CustomAlert.show(AlertType.error, 'Gagal', message);
    } catch (e) {
      CustomAlert.show(AlertType.error, 'Error Sistem', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}