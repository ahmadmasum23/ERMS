import 'package:get/get.dart';
import 'package:inven/app/data/models/AppUser.dart';
import 'package:inven/app/data/models/ProfilPengguna.dart';
import 'package:inven/app/global/bindings/InitialBinding.dart';
import 'package:inven/app/modules/login/controllers/login_controller.dart';
import 'package:inven/app/modules/login/views/login_view.dart';

class GlobalUserController extends GetxController {
  final user = Rxn<ProfilPengguna>();
   var user2 = Rxn<AppUser>();

  void setUser(ProfilPengguna model) {
    user.value = model;
  }

  void logout() async {
    user.value = null;
    
    // Clear login form if controller exists
    try {
      final login = Get.find<LoginController>();
      login.clearForm();
    } catch (e) {
      // LoginController not found, ignore
      print('LoginController not found: $e');
    }

    Get.offAll(() => LoginView(), );
    Get.offAll(() => LoginView(), binding: InitialBinding());
  }

  // Helper methods for role checking
  bool get isAdmin => user.value?.isAdmin ?? false;
  bool get isPetugas => user.value?.isPetugas ?? false;
  bool get isPeminjam => user.value?.isPeminjam ?? false;
  String get userId => user.value?.id ?? '';
  String get userName => user.value?.namaLengkap ?? '';
}
