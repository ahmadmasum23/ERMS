import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/data/models/Peminjaman.dart';
import 'package:inven/app/modules/operator/controllers/operator_controller.dart';
import 'package:inven/app/modules/borrower/views/riwayat/RiwayatTable.dart';

class PersetujuanBody extends GetView<OperatorController> {
  final Peminjaman model;

  const PersetujuanBody({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final id = model.id.toString();

    return Obx(() {
      final isExpanded = controller.expandP.value == id;

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xffF4F7F7),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Borrower information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.peminjam?.namaLengkap ??
                              'Peminjam tidak dikenal',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Keperluan: ${model.alasan ?? 'Tidak diisi'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Tanggal Pinjam: ${model.tanggalPinjam.toString().split(' ')[0]}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          'Tanggal Jatuh Tempo: ${model.tanggalJatuhTempo.toString().split(' ')[0]}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min, 
                    children: [
                      // Setujui button
                      Flexible(
                        fit: FlexFit.loose,
                        child: Container(
                          margin: const EdgeInsets.only(right: 5),
                          height: 40,
                          child: ElevatedButton(
                            onPressed: controller.bttnLoad.value
                                ? null
                                : () => controller.updtData(model.id, 2),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  5,
                                ), // radius 5
                              ),
                            ),
                            child: controller.bttnLoad.value
                                ? const SizedBox(width: 20, height: 20)
                                : const Text('Setujui'),
                          ),
                        ),
                      ),

                      // Tolak button
                      Flexible(
                        fit: FlexFit.loose,
                        child: Container(
                          margin: const EdgeInsets.only(right: 5),
                          height: 40,
                          child: ElevatedButton(
                            onPressed: controller.bttnLoad.value
                                ? null
                                : () => controller.updtData(model.id, 3),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  5,
                                ), // radius 5
                              ),
                            ),
                            child: controller.bttnLoad.value
                                ? const SizedBox(width: 20, height: 20)
                                : const Text('Tolak'),
                          ),
                        ),
                      ),

                      // Expand button
                      Container(
                        width: 40,
                        height: 43,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(5), // radius 5
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if (isExpanded) {
                              controller.expandP.value = '';
                            } else {
                              controller.expandP.value = id;
                            }
                          },
                          icon: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (isExpanded) ...[
              const SizedBox(height: 10),
              RiwayatTable(model: model.toAppPengajuan()),
            ],
          ],
        ),
      );
    });
  }
}
