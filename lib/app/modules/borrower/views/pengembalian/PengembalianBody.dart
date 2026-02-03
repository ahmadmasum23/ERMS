import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:inven/app/data/models/AppPengajuan.dart';
import 'package:inven/app/modules/operator/controllers/operator_controller.dart';

class PengembalianBody extends StatelessWidget {
  final AppPengajuan model;

  const PengembalianBody({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
final controller = Get.put(OperatorController());


    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pengembalian Barang #${model.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(model.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(model.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Detail
            _buildDetailRow('Tanggal Pinjam', model.tanggalPinjam.toString().split(' ')[0]),
            const SizedBox(height: 8),
            _buildDetailRow('Tanggal Jatuh Tempo', model.tanggalJatuhTempo.toString().split(' ')[0]),
            const SizedBox(height: 8),
            _buildDetailRow('Tanggal Kembali',
                model.tanggalKembali != null ? model.tanggalKembali.toString().split(' ')[0] : '-'),
            if (model.hariTerlambat > 0) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Hari Terlambat', '${model.hariTerlambat} hari'),
            ],
            if (model.alasan != null && model.alasan!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Alasan', model.alasan!),
            ],

            const SizedBox(height: 16),

            // Tombol Ajukan Pengembalian
            if (model.status.toLowerCase() != 'dikembalikan')
              Obx(() {
                return ElevatedButton(
                  onPressed: controller.bttnLoad.value
                      ? null
                      : () async {
                          final confirm = await Get.defaultDialog(
                            title: 'Konfirmasi',
                            middleText: 'Ajukan pengembalian untuk peminjaman ini?',
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
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
