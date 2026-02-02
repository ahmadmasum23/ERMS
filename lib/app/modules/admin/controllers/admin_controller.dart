import 'package:get/get.dart';
import 'package:inven/app/data/models/ProfilPengguna.dart';
import 'package:inven/app/global/controllers/global_inven_controller.dart';
import 'package:inven/app/global/controllers/global_user_controller.dart';
import 'package:inven/app/modules/login/controllers/login_controller.dart';
import 'package:inven/app/modules/login/views/login_view.dart';

class AdminController extends GetxController {
    late final GlobalUserController userCtrl;

  var isIndex = 0.obs;

   // METHOD YANG DIBUTUHKAN
  void changePage(int index) {
    isIndex.value = index;
  }

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
        userCtrl = Get.find<GlobalUserController>();

  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

    ProfilPengguna? get adminData => userCtrl.user.value;

    //logout app
  void doLogout() {
    Get.offAll(
      () => LoginView(),
      binding: BindingsBuilder(() {
        Get.put(GlobalUserController());
        Get.put(GlobalInvenController());
        Get.put(LoginController());
      }),
    );
  }
}