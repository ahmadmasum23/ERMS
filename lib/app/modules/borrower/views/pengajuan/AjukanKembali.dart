import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:inven/app/global/widgets/CustomDatePicker.dart';
import 'package:inven/app/modules/borrower/controllers/borrower_controller.dart';

class AjukanKembali extends GetView<BorrowerController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return CustomDatePicker(
        label: 'Pengembalian:',
        selectDate: controller.tglKembali.value,
        onDatePick: (val) {
          controller.tglKembali.value = val;
        },
      );
    });
  }
}
