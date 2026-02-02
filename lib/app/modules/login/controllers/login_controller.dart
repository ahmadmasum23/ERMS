import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:inven/app/data/services/database_service_provider.dart';
import 'package:inven/app/global/controllers/global_inven_controller.dart';
import 'package:inven/app/global/controllers/global_user_controller.dart';
import 'package:inven/app/routes/app_pages.dart';

class LoginController extends GetxController {
  final ctrlEmail = TextEditingController();
  final ctrlPass = TextEditingController();

  final fcsEmail = FocusNode();
  final fcsPass = FocusNode();

  final isPassHide = true.obs;
  var isLoading = false.obs;
  
  // Tambahkan variabel untuk error message
  var errorMessage = ''.obs;

  void toglePass() => isPassHide.value = !isPassHide.value;

  void clearForm() {
    ctrlEmail.clear();
    ctrlPass.clear();
    errorMessage.value = ''; // Reset error message
  }

  @override
  void onClose() {
    ctrlEmail.dispose();
    ctrlPass.dispose();
    fcsEmail.dispose();
    fcsPass.dispose();
    super.onClose();
  }

  Future<void> login(GlobalKey<FormState> loginKey) async {
    late final GlobalUserController userGlobal;
    try {
      userGlobal = Get.find<GlobalUserController>();
    } catch (e) {
      userGlobal = Get.put(GlobalUserController());
    }

    if (isLoading.value) return;
    if (!(loginKey.currentState?.validate() ?? false)) return;

    try {
      isLoading.value = true;
      errorMessage.value = ''; // Reset error

      final data = await DatabaseServiceProvider.login(
        ctrlEmail.text.trim(),
        ctrlPass.text.trim(),
      );

      if (data != null) {
        userGlobal.setUser(data);

        // Tampilkan snackbar sukses yang lebih baik
        Get.snackbar(
          '✓ Berhasil',
          'Selamat datang kembali, ${data.namaLengkap}!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(15),
          borderRadius: 10,
          duration: const Duration(seconds: 2),
        );

        // Fetch inventory data after successful login
        try {
          final invenController = Get.find<GlobalInvenController>();
          await invenController.fetchData();
          print('DEBUG: Inventory data fetched after login');
        } catch (e) {
          print('DEBUG: Could not fetch inventory data: $e');
        }

        await Future.delayed(const Duration(milliseconds: 800));

        switch (data.peran) {
          case 'admin':
            Get.offAllNamed(Routes.ADMIN);
            break;
          case 'petugas':
            Get.offAllNamed(Routes.OPERATOR);
            break;
          case 'peminjam':
            Get.offAllNamed(Routes.BORROWER);
            break;
          default:
            Get.snackbar(
              '⚠ Peringatan',
              'Role tidak dikenali',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
        }
      } else {
        // Error handling yang lebih baik untuk email/password salah
        errorMessage.value = 'Email atau password salah';
        
        Get.snackbar(
          '✗ Login Gagal',
          'Email atau password yang Anda masukkan salah',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(15),
          borderRadius: 10,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
        
        // Clear password field
        ctrlPass.clear();
        // Request focus kembali ke password
        Future.delayed(const Duration(milliseconds: 100), () {
          fcsPass.requestFocus();
        });
      }
    } catch (e) {
      // Error handling yang lebih spesifik
      String errorMsg = 'Terjadi kesalahan, Periksa kemabali email dan pasword anda pastikan sesuai dengan data anda';
      
      if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
        errorMsg = 'Koneksi timeout, periksa jaringan Anda';
      } else if (e.toString().contains('network') || e.toString().contains('Network')) {
        errorMsg = 'Tidak ada koneksi internet';
      } else if (e.toString().contains('401') || e.toString().contains('unauthorized')) {
        errorMsg = 'Autentikasi gagal';
      }
      
      errorMessage.value = errorMsg;
      
      Get.snackbar(
        '✗ Error',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
        borderRadius: 10,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline, color: Colors.white),
        shouldIconPulse: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}