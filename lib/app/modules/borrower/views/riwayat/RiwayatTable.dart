import 'package:flutter/material.dart';
import 'package:inven/app/data/models/AppPengajuan.dart';

class RiwayatTable extends StatelessWidget {
  final AppPengajuan model;

  const RiwayatTable({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Pengajuan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            _buildRow('ID Peminjaman', model.id.toString()),
            _buildRow('Tanggal Pinjam', model.tanggalPinjam.toString().split(' ')[0]),
            _buildRow('Tanggal Jatuh Tempo', model.tanggalJatuhTempo.toString().split(' ')[0]),
            _buildRow('Status', _getStatusDisplay(model.status)),
            if (model.tanggalKembali != null)
              _buildRow('Tanggal Kembali', model.tanggalKembali!.toString().split(' ')[0]),
            if (model.hariTerlambat > 0)
              _buildRow('Hari Terlambat', model.hariTerlambat.toString()),
            if (model.alasan != null && model.alasan!.isNotEmpty)
              _buildRow('Alasan', model.alasan!),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(':'),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusDisplay(String status) {
    switch (status) {
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