import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:inven/app/data/models/AppPengajuan.dart';
import 'package:inven/app/modules/operator/controllers/operator_controller.dart';
class PengembalianBody extends StatelessWidget {
  final AppPengajuan model;

  const PengembalianBody({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OperatorController());

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xffF4F7F7),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    /// 🔹 HEADER
    Row(
      children: [
        const Icon(Icons.inventory_2_outlined, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "Transaksi Peminjaman #${model.id}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(model.status),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _getStatusText(model.status),
            style: const TextStyle(color: Colors.white),
          ),
        )
      ],
    ),

    const SizedBox(height: 16),

    /// 🔹 INFO DETAIL
    _buildDetailRow(
      'Tanggal Pinjam',
      model.tanggalPinjam.toString().split(' ')[0],
    ),
    const SizedBox(height: 8),

    _buildDetailRow(
      'Jatuh Tempo',
      model.tanggalJatuhTempo.toString().split(' ')[0],
    ),
    const SizedBox(height: 8),

    _buildDetailRow(
      'Tanggal Kembali',
      model.tanggalKembali != null
          ? model.tanggalKembali.toString().split(' ')[0]
          : '-',
    ),

    if (model.hariTerlambat > 0) ...[
      const SizedBox(height: 8),
      _buildDetailRow('Terlambat', '${model.hariTerlambat} hari'),
    ],

    if (model.alasan != null && model.alasan!.isNotEmpty) ...[
      const SizedBox(height: 8),
      _buildDetailRow('Alasan', model.alasan!),
    ],

    const SizedBox(height: 16),

    /// 🔹 TOMBOL AKSI
    if (model.status.toLowerCase() != 'tunggu_pinjam')
      Obx(() {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.bttnLoad.value
                ? null
                : () async {
                    final confirm = await Get.defaultDialog(
                      title: 'Konfirmasi',
                      middleText:
                          'Ajukan pengembalian untuk transaksi ini?',
                      textConfirm: 'Ya',
                      textCancel: 'Batal',
                      onConfirm: () => Get.back(result: true),
                      onCancel: () => Get.back(result: false),
                    );

                    if (confirm == true) {
                      await controller.ajukanPengembalian(model.id);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // tombol kotak
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
                : const Text('Ajukan Pengembalian'),
          ),
        );
      }),
  ],
),

      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700]))),
        Expanded(
            flex: 3,
            child: Text(value,
                style: const TextStyle(color: Colors.black87))),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Colors.orange;
      case 'disetujui':
        return Colors.blue;
      case 'ditolak':
        return Colors.red;
      case 'dikembalikan':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return 'Menunggu';
      case 'disetujui':
        return 'Disetujui';
      case 'ditolak':
        return 'Ditolak';
      case 'dikembalikan':
        return 'Dikembalikan';
      default:
        return status;
    }
  }
}
