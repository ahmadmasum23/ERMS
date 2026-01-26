import 'package:get/get.dart';
import 'package:inven/app/modules/admin/controllers/admin_edit_controller.dart';

import '../controllers/admin_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminController>(
      () => AdminController(),
    );
    Get.lazyPut<AdminEditController>(() => AdminEditController());
  }
  
}
