import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';
import 'package:inven/app/global/widgets/CustomFilterChips.dart';
import 'package:inven/app/modules/borrower/controllers/borrower_controller.dart';
import 'RiwayatBody.dart';

class RiwayatPanel extends GetView<BorrowerController> {
  const RiwayatPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AppBar kustom
        const CustomAppbar(
          title: 'Riwayat',
          boldTitle: 'Peminjaman',
          showNotif: false,
        ),

        // Filter + Refresh
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() {
                return Expanded(
                  child: CustomFilterChips(
                    opsi: controller.opsFltr,
                    select: controller.slctOps.value,
                    isSelect: (val) {
                      controller.slctOps.value = val;
                      controller.filterChips();
                    },
                  ),
                );
              }),
              IconButton(
                onPressed: () {
                  controller.refresh();
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),

        // List Riwayat
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.riwayatFltr.isEmpty) {
                return const Center(child: Text('Tidak ada riwayat peminjaman'));
              }

              return ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: controller.riwayatFltr.length,
                itemBuilder: (context, index) {
                  final item = controller.riwayatFltr[index];
                  return RiwayatBody(model: item);
                },
                separatorBuilder: (context, index) => const SizedBox(height: 8),
              );
            }),
          ),
        ),
      ],
    );
  }
}
