import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smartkoi/app/features/authentication/controllers/auth_controller.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Variabel lokal untuk UI (Show/Hide Password)
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    // Kita gunakan Get.find karena Controller biasanya sudah di-put di halaman Login/Splash
    // Jika error "Controller not found", ganti jadi Get.put(AuthController())
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white, onPressed: () => Get.back()),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan.shade300, Colors.blue.shade800],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Form Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  // Menambahkan shadow agar konsisten dengan LoginScreen
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Buat Akun',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(color: Colors.grey[600]),
                        children: [
                          const TextSpan(text: "Sudah punya akun? "),
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Get.back(), // Kembali ke halaman Login
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- NAMA DEPAN ---
                    TextField(
                      controller: authController.firstNameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next, // Pindah ke kolom berikutnya
                      decoration: const InputDecoration(
                        labelText: 'Nama Depan',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Iconsax.user),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- NAMA BELAKANG ---
                    TextField(
                      controller: authController.lastNameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nama Belakang',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Iconsax.user_add),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- EMAIL ---
                    TextField(
                      controller: authController.emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Iconsax.direct),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- PASSWORD ---
                    TextField(
                      controller: authController.passwordController,
                      obscureText: !_isPasswordVisible,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Iconsax.key),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash
                          ),
                          onPressed: () => setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- KONFIRMASI PASSWORD ---
                    TextField(
                      controller: authController.confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      textInputAction: TextInputAction.done, // Selesai mengetik
                      onSubmitted: (_) => authController.signUpUser(), // Tekan enter langsung daftar
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Iconsax.key_square),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _isConfirmPasswordVisible ? Iconsax.eye : Iconsax.eye_slash
                          ),
                          onPressed: () => setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- TOMBOL DAFTAR ---
                    Obx(() {
                      return ElevatedButton(
                        onPressed: authController.isLoading.value
                            ? null
                            : () => authController.signUpUser(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: authController.isLoading.value
                            ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                        )
                            : const Text('Daftar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}