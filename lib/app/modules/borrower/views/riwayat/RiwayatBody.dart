import 'package:flutter/material.dart';
import 'package:inven/app/data/models/AppPengajuan.dart';

class RiwayatBody extends StatelessWidget {
  final AppPengajuan model;

  const RiwayatBody({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xffF4F7F7),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ID + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Peminjaman #${model.id}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(model.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    model.status,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Tanggal
            Text('Tanggal Pinjam: ${model.tanggalPinjam.toString().split(' ')[0]}'),
            Text(
                'Tanggal Jatuh Tempo: ${model.tanggalJatuhTempo.toString().split(' ')[0]}'),
            Text(
                'Tanggal Kembali: ${model.tanggalKembali != null ? model.tanggalKembali.toString().split(' ')[0] : '-'}'),

            if (model.hariTerlambat > 0)
              Text('Terlambat: ${model.hariTerlambat} hari'),
            if (model.alasan != null && model.alasan!.isNotEmpty)
              Text('Alasan: ${model.alasan}'),

            const SizedBox(height: 12),

            // List Alat
            const Text(
              'Alat yang dipinjam:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            if (model.detailAlat != null && model.detailAlat!.isNotEmpty)
              ...model.detailAlat!.map(
                (d) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          d.alat?.nama ?? '-',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        d.kondisiSaatPinjam ?? '-',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Text('-'),
          ],
        ),
      ),
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
}
