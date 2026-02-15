import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smartkoi/app/features/authentication/controllers/auth_controller.dart';
import 'package:smartkoi/app/features/authentication/screens/forgot_password_screen.dart';
import 'package:smartkoi/app/features/authentication/screens/signup_screen.dart';

// REVISI: Menggunakan StatelessWidget karena state diurus oleh GetX Controller
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Memastikan controller tersedia. Menggunakan Get.put agar aman jika belum di-inject sebelumnya.
    final AuthController authController = Get.put(AuthController());

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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
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
                      'Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(color: Colors.grey[600]),
                        children: [
                          const TextSpan(text: "Belum punya akun? "),
                          TextSpan(
                            text: 'Daftar',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Get.off(() => const SignUpScreen()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- INPUT EMAIL ---
                    TextField(
                      controller: authController.emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next, // Pindah ke bawah saat enter
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Iconsax.direct),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- INPUT PASSWORD ---
                    // Menggunakan Obx agar ikon mata dan text berubah real-time
                    Obx(() => TextField(
                      controller: authController.passwordController,
                      obscureText: authController.isPasswordHidden.value,
                      textInputAction: TextInputAction.done, // Selesai saat enter
                      onSubmitted: (_) => authController.signInUser(), // Langsung login saat enter
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Iconsax.key),
                        suffixIcon: IconButton(
                          icon: Icon(
                            authController.isPasswordHidden.value
                                ? Iconsax.eye_slash
                                : Iconsax.eye,
                          ),
                          onPressed: () => authController.togglePasswordVisibility(),
                        ),
                      ),
                    )),

                    const SizedBox(height: 4),

                    // --- FORGOT PASSWORD ---
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Get.to(() => const ForgotPasswordScreen()),
                        child: Text(
                          'Lupa Password?',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // --- TOMBOL LOGIN ---
                    Obx(() {
                      return ElevatedButton(
                        onPressed: authController.isLoading.value
                            ? null
                            : () => authController.signInUser(),
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
                            : const Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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