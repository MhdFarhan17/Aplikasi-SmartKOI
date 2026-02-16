import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smartkoi/app/features/profile/controllers/profile_controller.dart';
import 'package:smartkoi/app/features/authentication/screens/welcome_screen.dart';
import 'package:smartkoi/app/data/models/user_model.dart';
import 'package:smartkoi/app/shared/widgets/custom_dialog.dart';
import 'package:smartkoi/app/shared/widgets/alert_helper.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        // State Loading awal
        if (controller.user.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.user.value!;
        // Menampilkan inisial nama (Misal: Muhammad Farhan -> MF)
        final String initials =
            "${user.firstName.isNotEmpty ? user.firstName[0] : ''}"
            "${user.lastName.isNotEmpty ? user.lastName[0] : ''}";

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          children: [
            // Header: Foto & Info Dasar
            _buildProfileHeader(
              context,
              initials.toUpperCase(),
              '${user.firstName} ${user.lastName}',
              user.email,
            ),
            const SizedBox(height: 30),

            // Section: Akun
            _buildSectionTitle('Pengaturan Akun'),
            const SizedBox(height: 10),
            _buildSettingsCard(context, controller, user),

            const SizedBox(height: 30),

            // Section: Umum
            _buildSectionTitle('Umum'),
            const SizedBox(height: 10),
            _buildGeneralCard(context),

            // Info Versi kecil di bawah
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Versi 1.0.0",
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      }),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildProfileHeader(
      BuildContext context, String initials, String fullName, String email) {
    return Card(
      elevation: 4.0,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                  color: Colors.blue[800],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ]
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
      BuildContext context, ProfileController controller, UserModel user) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle
              ),
              child: Icon(Iconsax.user_edit, color: Colors.blue[700], size: 20),
            ),
            title: const Text('Ubah Nama', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey[400]),
            onTap: () => _showUpdateNameDialog(context, controller, user),
          ),
          Divider(height: 1, indent: 60, endIndent: 20, color: Colors.grey[200]),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle
              ),
              child: Icon(Iconsax.key, color: Colors.blue[700], size: 20),
            ),
            title: const Text('Ubah Kata Sandi', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey[400]),
            onTap: () => _showChangePasswordDialog(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle
              ),
              child: Icon(Iconsax.info_circle, color: Colors.blue[700], size: 20),
            ),
            title: const Text('Tentang Aplikasi', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey[400]),
            onTap: () => _showAboutAppDialog(context),
          ),
          Divider(height: 1, indent: 60, endIndent: 20, color: Colors.grey[200]),

          // TOMBOL LOGOUT
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle
              ),
              child: Icon(Iconsax.logout, color: Colors.red[700], size: 20),
            ),
            title: Text(
              'Keluar Akun',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _showLogoutConfirmationDialog(context),
          ),
        ],
      ),
    );
  }

  // --- DIALOGS ---

// 1. Dialog About App
  void _showAboutAppDialog(BuildContext context) {
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- 1. LOGO APLIKASI ---
              Container(
                height: 90,
                width: 90,
                padding: const EdgeInsets.all(4), // Memberi jarak antara border dan gambar
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.blue.shade100, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/icon-app.png',
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, error, stackTrace) =>
                        Icon(Iconsax.autobrightness, size: 40, color: Colors.blue[700]),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- 2. NAMA & VERSI APLIKASI ---
              const Text(
                'SmartKOI',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              // Badge Versi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  'Versi 1.0.0',
                  style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // --- 3. DESKRIPSI ---
              const Text(
                'Sistem monitoring secara real-time untuk kualitas air, informasi status aktuator, dan informasi detail baterai sebagai daya cadangan untuk Akuarium Ikan Koi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: Colors.black54),
              ),
              const SizedBox(height: 24),

              // --- 4. KARTU DEVELOPER (DEVELOPER INFO) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      'DIKEMBANGKAN OLEH',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Muhammad Farhan',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue[900]),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Teknik Elektro UNDIP',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Konsentrasi Teknologi Informasi',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // --- 5. TOMBOL TUTUP ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Dialog Ubah Password
  void _showChangePasswordDialog(
      BuildContext context, ProfileController controller) {
    if (controller.isLoading.value) return;

    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    Get.dialog(
      CustomActionDialog(
        title: 'Ubah Kata Sandi',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan kata sandi lama untuk verifikasi, lalu buat kata sandi baru.',
              style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 20),

            // Password Lama
            TextField(
              controller: currentPassController,
              obscureText: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Kata Sandi Lama',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Iconsax.lock),
              ),
            ),
            const SizedBox(height: 16),

            // Password Baru
            TextField(
              controller: newPassController,
              obscureText: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Kata Sandi Baru',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Iconsax.key),
              ),
            ),
            const SizedBox(height: 16),

            // Konfirmasi Password
            TextField(
              controller: confirmPassController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                // Trigger logic manual agar UX seperti tombol enter
                if (newPassController.text != confirmPassController.text) {
                  CustomAlert.show(AlertType.warning, 'Tidak Cocok', 'Kata sandi baru tidak sama.');
                } else {
                  controller.changePassword(
                      currentPassController.text, newPassController.text);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Sandi Baru',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Iconsax.key_square),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          const SizedBox(width: 8),
          Obx(() => controller.isLoading.value
              ? const SizedBox(
              height: 20, width: 20,
              child: CircularProgressIndicator(strokeWidth: 2)
          )
              : ElevatedButton(
            onPressed: () {
              if (newPassController.text != confirmPassController.text) {
                CustomAlert.show(AlertType.warning, 'Tidak Cocok', 'Kata sandi baru tidak sama.');
                return;
              }
              if (newPassController.text.length < 6) {
                CustomAlert.show(AlertType.warning, 'Lemah', 'Kata sandi minimal 6 karakter.');
                return;
              }
              controller.changePassword(
                  currentPassController.text, newPassController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Simpan'),
          )
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // 3. Dialog Ubah Nama
  void _showUpdateNameDialog(
      BuildContext context, ProfileController controller, UserModel currentUser) {
    if (controller.isLoading.value) return;

    final firstNameController = TextEditingController(text: currentUser.firstName);
    final lastNameController = TextEditingController(text: currentUser.lastName);

    Get.dialog(
      CustomActionDialog(
        title: 'Ubah Nama Profil',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Depan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Iconsax.user),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Belakang',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Iconsax.user_edit),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                controller.updateUserName(
                    firstNameController.text, lastNameController.text);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          const SizedBox(width: 8),
          Obx(() => controller.isLoading.value
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : ElevatedButton(
            onPressed: () {
              controller.updateUserName(
                  firstNameController.text, lastNameController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Simpan'),
          )
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // 4. Dialog Logout
  void _showLogoutConfirmationDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.logout, color: Colors.red[700], size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Konfirmasi Keluar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Apakah Anda yakin ingin keluar dari akun ini?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Bersihkan state jika perlu
                        await FirebaseAuth.instance.signOut();
                        Get.offAll(() => const WelcomeScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}