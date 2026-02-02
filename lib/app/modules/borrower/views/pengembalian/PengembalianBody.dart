import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:inven/app/data/models/AppPengajuan.dart';

class PengembalianBody extends StatelessWidget {
  final AppPengajuan model;

  const PengembalianBody({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pengembalian Barang #${model.id}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(model.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(model.status),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildDetailRow('Tanggal Pinjam', 
              model.tanggalPinjam.toString().split(' ')[0]),
            SizedBox(height: 8),
            _buildDetailRow('Tanggal Jatuh Tempo', 
              model.tanggalJatuhTempo.toString().split(' ')[0]),
            SizedBox(height: 8),
            _buildDetailRow('Tanggal Kembali', 
              model.tanggalKembali != null 
                ? model.tanggalKembali.toString().split(' ')[0] 
                : '-'),
            if (model.hariTerlambat > 0) ...[
              SizedBox(height: 8),
              _buildDetailRow('Hari Terlambat', '${model.hariTerlambat} hari'),
            ],
            if (model.alasan != null && model.alasan!.isNotEmpty) ...[
              SizedBox(height: 8),
              _buildDetailRow('Alasan', model.alasan!),
            ],
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
            style: TextStyle(
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