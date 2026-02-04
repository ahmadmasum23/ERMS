import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';
import 'package:inven/app/global/widgets/CustomTxtForm.dart';
import 'package:inven/app/modules/operator/controllers/operator_controller.dart';
import 'package:inven/app/modules/operator/views/persetujuan/PersetujuanBody.dart';


class PersetujuanPanel extends GetView<OperatorController> {
  const PersetujuanPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppbar(title: 'Proses', boldTitle: 'Pengajuan', showNotif: false),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CustomTxtForm(
            Label: 'Cari barang',
            Controller: controller.ctrlFill,
            Focus: controller.focusFil,
            OnSubmit: (_) {
              controller.filterD();
            },
            OnChange: (_) {
              controller.filterD();
            },
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              // Filter for pending applications (status = 'menunggu')
              final pendingApplications = controller.pengajuan
                  .where((p) => p.status == 'tunggu_pinjam')
                  .toList();
              
              if (pendingApplications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada pengajuan yang menunggu persetujuan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(0),
                itemBuilder: (context, index) {
                  final item = pendingApplications[index];
                  return PersetujuanBody(model: item);
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 10);
                },
                itemCount: pendingApplications.length,
              );
            }),
          ),
        ),
      ],
    );
  }
}
