import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:inven/app/data/services/database_service_provider.dart';
import 'package:inven/app/global/controllers/global_user_controller.dart';
import 'package:inven/app/routes/app_pages.dart';

class LoginController extends GetxController {
  final ctrlEmail = TextEditingController();
  final ctrlPass = TextEditingController();

  final fcsEmail = FocusNode();
  final fcsPass = FocusNode();

  final isPassHide = true.obs;
  var isLoading = false.obs;

  void toglePass() => isPassHide.value = !isPassHide.value;

  void clearForm() {
    ctrlEmail.clear();
    ctrlPass.clear();
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
    final userGlobal = Get.find<GlobalUserController>();

    if (isLoading.value) return;
    if (!(loginKey.currentState?.validate() ?? false)) return;

    try {
      isLoading.value = true;

      final data = await DatabaseServiceProvider.login(
        ctrlEmail.text.trim(),
        ctrlPass.text.trim(),
      );

      if (data != null) {
        userGlobal.setUser(data);

        Get.snackbar('Sukses', 'Berhasil login');

        await Future.delayed(const Duration(milliseconds: 800));

        switch (data.peranId) {
          case 1:
            Get.offAllNamed(Routes.ADMIN);
            break;
          case 2:
            Get.offAllNamed(Routes.OPERATOR);
            break;
          case 3:
            Get.offAllNamed(Routes.BORROWER);
            break;
          default:
            Get.snackbar('Error', 'Role tidak dikenali');
        }
      } else {
        Get.snackbar('Error', 'Email atau password salah');
      }
    } catch (e) {
      Get.snackbar('Error', 'Login gagal: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
