import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartkoi/app/shared/widgets/alert_helper.dart';
import 'package:smartkoi/app/data/repositories/auth_repository.dart';
import 'package:smartkoi/app/features/authentication/screens/login_screen.dart';
import 'package:smartkoi/app/features/dashboard/screens/dashboard_screen.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  // State Variables
  final isLoading = false.obs;
  final isPasswordHidden = true.obs; // Untuk fitur show/hide password

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController forgotPasswordEmailController;

  @override
  void onInit() {
    super.onInit();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    forgotPasswordEmailController = TextEditingController();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    forgotPasswordEmailController.dispose();
    super.onClose();
  }

  void clearControllers() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    forgotPasswordEmailController.clear();
  }

  // Fungsi untuk mengubah visibilitas password (mata)
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // --- REGISTER / SIGN UP ---
  Future<void> signUpUser() async {
    if (isLoading.value) return;

    // 1. Validasi Input Kosong
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      CustomAlert.show(
          AlertType.warning,
          'Input Diperlukan',
          'Semua kolom harus diisi.'
      );
      return;
    }

    // 2. Validasi Format Email
    if (!GetUtils.isEmail(emailController.text.trim())) {
      CustomAlert.show(
          AlertType.warning,
          'Email Tidak Valid',
          'Mohon masukkan format email yang benar.'
      );
      return;
    }

    // 3. Validasi Kecocokan Password
    if (passwordController.text != confirmPasswordController.text) {
      CustomAlert.show(
          AlertType.error,
          'Password Tidak Cocok',
          'Password dan Konfirmasi Password tidak sama.'
      );
      return;
    }

    // 4. Validasi Panjang Password
    if (passwordController.text.length < 6) {
      CustomAlert.show(
          AlertType.warning,
          'Password Lemah',
          'Password harus minimal 6 karakter.'
      );
      return;
    }

    isLoading.value = true;
    try {
      await _authRepository.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
      );

      await _authRepository.sendEmailVerification();
      await _authRepository.signOut();

      CustomAlert.show(
          AlertType.success,
          'Pendaftaran Berhasil',
          'Cek email Anda untuk verifikasi sebelum login.'
      );

      clearControllers();
      Get.offAll(() => const LoginScreen());

    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan yang tidak diketahui.';
      if (e.code == 'email-already-in-use') {
        message = 'Alamat email tersebut sudah digunakan oleh akun lain.';
      } else if (e.code == 'invalid-email') {
        message = 'Alamat email tersebut tidak valid.';
      } else if (e.code == 'weak-password') {
        message = 'Password terlalu lemah.';
      }
      CustomAlert.show(AlertType.error, 'Gagal Daftar', message);
    } catch (e) {
      CustomAlert.show(AlertType.error, 'Error Sistem', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIN / SIGN IN ---
  Future<void> signInUser() async {
    if (isLoading.value) return;

    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      CustomAlert.show(
          AlertType.warning,
          'Input Diperlukan',
          'Email dan password harus diisi.'
      );
      return;
    }

    isLoading.value = true;
    try {
      await _authRepository.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        await _authRepository.signOut();
        CustomAlert.show(
            AlertType.warning,
            'Email Belum Diverifikasi',
            'Silakan periksa email Anda untuk verifikasi.'
        );
        return;
      }

      clearControllers();
      Get.offAll(() => const DashboardScreen());

    } on FirebaseAuthException catch (e) {
      String message = 'Periksa kembali email dan password Anda.';
      if (e.code == 'user-not-found') {
        message = 'Akun dengan email ini tidak ditemukan.';
      } else if (e.code == 'wrong-password') { // Catatan: Firebase terbaru mungkin menyatukan error ini untuk keamanan
        message = 'Password salah.';
      } else if (e.code == 'invalid-email') {
        message = 'Format email salah.';
      } else if (e.code == 'user-disabled') {
        message = 'Akun ini telah dinonaktifkan.';
      } else if (e.code == 'too-many-requests') {
        message = 'Terlalu banyak percobaan. Coba lagi nanti.';
      } else if (e.code == 'invalid-credential') {
        message = 'Email atau password salah.';
      }
      CustomAlert.show(AlertType.error, 'Login Gagal', message);
    } catch (e) {
      CustomAlert.show(AlertType.error, 'Login Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // --- FORGOT PASSWORD ---
  Future<void> sendPasswordResetLink() async {
    if (isLoading.value) return;

    if (forgotPasswordEmailController.text.trim().isEmpty) {
      CustomAlert.show(
          AlertType.warning,
          'Input Kosong',
          'Masukkan alamat email Anda.'
      );
      return;
    }

    if (!GetUtils.isEmail(forgotPasswordEmailController.text.trim())) {
      CustomAlert.show(
          AlertType.warning,
          'Email Tidak Valid',
          'Mohon masukkan format email yang benar.'
      );
      return;
    }

    isLoading.value = true;
    try {
      final email = forgotPasswordEmailController.text.trim();
      await _authRepository.forgotPassword(
        email: email,
      );

      Get.back(); // Tutup dialog/bottom sheet
      CustomAlert.show(
          AlertType.success,
          'Link Terkirim',
          'Link reset password dikirim ke $email. Cek Kotak Masuk/Spam.'
      );

    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan.';
      if (e.code == 'user-not-found') {
        message = 'Email tidak terdaftar.';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid.';
      }
      CustomAlert.show(AlertType.error, 'Gagal Kirim Link', message);
    } catch (e) {
      CustomAlert.show(AlertType.error, 'Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}