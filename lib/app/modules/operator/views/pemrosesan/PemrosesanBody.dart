import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/data/models/Peminjaman.dart';
import 'package:inven/app/modules/operator/controllers/operator_controller.dart';
import 'package:inven/app/modules/borrower/views/riwayat/RiwayatTable.dart';

class PemrosesanBody extends GetView<OperatorController> {
  final Peminjaman model;

  const PemrosesanBody({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final id = model.id.toString();

    return Obx(() {
      final isExpanded = controller.expandB.value == id;

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
            // Header informasi peminjaman
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xffF4F7F7),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Info peminjam & peminjaman
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
                        Text(
                          'Tanggal Kembali: ${model.tanggalKembali != null ? model.tanggalKembali.toString().split(' ')[0] : '-'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        if (model.hariTerlambat > 0)
                          Text(
                            'Hari Terlambat: ${model.hariTerlambat} hari',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                        if (model.status.toLowerCase() == 'menunggu_pengembalian')
                          Text(
                            'Status: Menunggu Pengembalian',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Tombol aksi (Operator)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Setujui pengembalian
                      if (model.status.toLowerCase() == 'menunggu_pengembalian')
                        Container(
                          margin: const EdgeInsets.only(right: 5),
                          height: 40,
                          child: ElevatedButton(
                            onPressed: controller.bttnLoad.value
                                ? null
                                : () => controller.updtData(model.id, 2),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: controller.bttnLoad.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Setujui'),
                          ),
                        ),

                      // Tolak pengembalian
                      if (model.status.toLowerCase() == 'menunggu_pengembalian')
                        Container(
                          margin: const EdgeInsets.only(right: 5),
                          height: 40,
                          child: ElevatedButton(
                            onPressed: controller.bttnLoad.value
                                ? null
                                : () => controller.updtData(model.id, 3),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: controller.bttnLoad.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Tolak'),
                          ),
                        ),

                      // Expand/collapse detail
                      Container(
                        width: 40,
                        height: 43,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            controller.expandB.value =
                                isExpanded ? '' : id;
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

            // Detail table (expand)
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
