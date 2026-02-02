import 'package:get/get.dart';
import 'package:inven/app/global/controllers/global_inven_controller.dart';
import 'package:inven/app/global/controllers/global_user_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    print('DEBUG: Initializing GlobalInvenController');
    Get.put<GlobalInvenController>(GlobalInvenController(), permanent: true);
    print('DEBUG: GlobalInvenController initialized');
    
    print('DEBUG: Initializing GlobalUserController');
    Get.put<GlobalUserController>(GlobalUserController(), permanent: true);
    print('DEBUG: GlobalUserController initialized');
  }
}
