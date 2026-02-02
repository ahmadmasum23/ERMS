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
                children: [
                  // Borrower information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.peminjam?.namaLengkap ?? 'Peminjam tidak dikenal',
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
                    children: [
                      // Approve button
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: ElevatedButton(
                          onPressed: controller.bttnLoad.value 
                            ? null 
                            : () => controller.updtData(model.id, 2), // 2 = Disetujui
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                          ),
                          child: controller.bttnLoad.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Setujui'),
                        ),
                      ),
                      
                      // Reject button
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: ElevatedButton(
                          onPressed: controller.bttnLoad.value 
                            ? null 
                            : () => controller.updtData(model.id, 3), // 3 = Ditolak
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                          ),
                          child: controller.bttnLoad.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Tolak'),
                        ),
                      ),
                      
                      // Expand button
                      IconButton(
                        onPressed: () {
                          if (isExpanded) {
                            controller.expandP.value = '';
                          } else {
                            controller.expandP.value = id;
                          }
                        },
                        icon: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.grey.shade700,
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