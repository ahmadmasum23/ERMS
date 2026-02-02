import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:inven/app/data/models/AppPengajuan.dart';
import 'package:inven/app/modules/borrower/controllers/borrower_controller.dart';

import 'package:inven/app/modules/borrower/views/riwayat/RiwayatTable.dart';

class RiwayatBody extends GetView<BorrowerController> {
  final AppPengajuan model;

  const RiwayatBody({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final id = model.id.toString();

    return Obx(() {
      final isExpand = controller.expandR.value == id;

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xffF4F7F7),
                borderRadius: BorderRadius.circular(5),
              ),
              
            ),

            if (isExpand) ...[
              const SizedBox(height: 10),

              RiwayatTable(model: model),
            ],
          ],
        ),
      );
    });
  }
}
