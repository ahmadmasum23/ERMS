import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/global/widgets/CustomDatePicker.dart';
import 'package:inven/app/modules/borrower/controllers/borrower_controller.dart';

class AjukanPinjam extends GetView<BorrowerController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return CustomDatePicker(
        label: 'Peminjaman:',
        selectDate: controller.tglPinjam.value,
        onDatePick: (val) {
          controller.tglPinjam.value = val;
        },
      );
    });
  }
}
