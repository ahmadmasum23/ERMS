import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';
import 'package:inven/app/global/widgets/CustomFilterChips.dart';
import 'package:inven/app/modules/operator/controllers/operator_controller.dart';

class OpRiwayatPanel extends GetView<OperatorController> {
  const OpRiwayatPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AppBar
        CustomAppbar(
          title: 'Riwayat',
          boldTitle: 'Pengajuan',
          showNotif: false,
        ),

        // Filter Chips dan Refresh
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Obx(
                () => Expanded(
                  child: CustomFilterChips(
                    opsi: controller.opsiFilter,
                    select: controller.selectOpsi.value,
                    isSelect: (val) {
                      controller.selectOpsi.value = val;
                      controller.filterChips();
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: () => controller.refresh(),
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

              if (controller.riwayatFilter.isEmpty) {
                return const Center(child: Text('Data kosong'));
              }

              return ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: controller.riwayatFilter.length,
                separatorBuilder: (context, index) => const SizedBox(height: 5),
                itemBuilder: (context, index) {
                  final item = controller.riwayatFilter[index];

                  // Warna berdasarkan status
                  Color statusColor;
                  switch (item.status) {
                    case 'disetujui':
                      statusColor = Colors.green.shade100;
                      break;
                    case 'ditolak':
                      statusColor = Colors.red.shade100;
                      break;
                    case 'menunggu':
                    default:
                      statusColor = Colors.yellow.shade100;
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama Peminjam
                        Text(
                          item.peminjam?.namaLengkap ?? '-',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 5),

                        // Tanggal Pinjam
                        Text(
                            'Tanggal Pinjam: ${item.tanggalPinjam.toLocal().toString().split(' ')[0]}'),

                        // Alasan jika ada
                        if (item.alasan != null && item.alasan!.isNotEmpty)
                          Text('Alasan: ${item.alasan}'),

                        const SizedBox(height: 5),

                        // Status dan Tanggal Kembali
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                item.status!.toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (item.tanggalKembali != null)
                              Text(
                                  'Kembali: ${item.tanggalKembali!.toLocal().toString().split(' ')[0]}'),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}
