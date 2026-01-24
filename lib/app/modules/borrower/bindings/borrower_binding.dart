import 'package:get/get.dart';

import '../controllers/borrower_controller.dart';

class BorrowerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BorrowerController>(() => BorrowerController());
  }
}
