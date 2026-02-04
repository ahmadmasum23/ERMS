import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inven/app/data/models/Peminjaman.dart';
import 'package:inven/app/modules/operator/controllers/operator_controller.dart';
import 'package:inven/app/modules/borrower/views/riwayat/RiwayatTable.dart';

class PemrosesanBody extends GetView<OperatorController> {
  final Peminjaman model;

  const PemrosesanBody({required this.model, super.key});

  String formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final id = model.id.toString();

    // Loading per tombol
    final isApproveLoading = false.obs;
    final isRejectLoading = false.obs;
    final isDendaLoading = false.obs;

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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 5),
                        Text('Tanggal Pinjam: ${formatDate(model.tanggalPinjam)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                        Text('Tanggal Jatuh Tempo: ${formatDate(model.tanggalJatuhTempo)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                        Text('Tanggal Kembali: ${formatDate(model.tanggalKembali)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                        if (model.hariTerlambat > 0)
                          Text('Hari Terlambat: ${model.hariTerlambat} hari',
                              style: TextStyle(fontSize: 12, color: Colors.red.shade700)),
                        if (model.status.toLowerCase() == 'tunggu_pengembalian')
                          Text('Status: Menunggu Pengembalian',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800)),
                      ],
                    ),
                  ),

                  // Tombol aksi (Operator)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Setujui pengembalian
                      if (model.status.toLowerCase() == 'tunggu_pengembalian')
                        Container(
                          margin: const EdgeInsets.only(right: 5),
                          height: 40,
                          child: Obx(() => ElevatedButton(
                                onPressed: isApproveLoading.value
                                    ? null
                                    : () async {
                                        isApproveLoading.value = true;
                                        await controller.updtData(model.id, 5);
                                        isApproveLoading.value = false;
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                ),
                                child: isApproveLoading.value
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Setujui'),
                              )),
                        ),

                      // Tolak pengembalian
                      if (model.status.toLowerCase() == 'tunggu_pengembalian')
                        Container(
                          margin: const EdgeInsets.only(right: 5),
                          height: 40,
                          child: Obx(() => ElevatedButton(
                                onPressed: isRejectLoading.value
                                    ? null
                                    : () async {
                                        isRejectLoading.value = true;
                                        await controller.updtData(model.id, 6);
                                        isRejectLoading.value = false;
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                ),
                                child: isRejectLoading.value
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Tolak'),
                              )),
                        ),

                      // Beri Denda
                      if (model.status.toLowerCase() == 'tunggu_pengembalian' ||
                          model.status.toLowerCase() == 'dikembalikan')
                        Container(
                          margin: const EdgeInsets.only(right: 5),
                          height: 40,
                          child: Obx(() => ElevatedButton(
                                onPressed: isDendaLoading.value
                                    ? null
                                    : () async {
                                        isDendaLoading.value = true;
                                        await controller.showDendaDialog(
                                            peminjamanId: model.id,
                                            isApprove: true,
                                            model: model);
                                        isDendaLoading.value = false;
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                ),
                                child: isDendaLoading.value
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.attach_money, size: 16),
                                          SizedBox(width: 5),
                                          Text('Beri Denda'),
                                        ],
                                      ),
                              )),
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
                            controller.expandB.value = isExpanded ? '' : id;
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
