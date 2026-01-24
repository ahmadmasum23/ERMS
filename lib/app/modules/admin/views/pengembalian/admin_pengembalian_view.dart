import 'package:flutter/material.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';

class AdminPengembalianView extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AdminPengembalianView({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppbar(
          title: 'Pengembalian',
          boldTitle: 'Panel',
          showNotif: false,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtitle
                Text(
                  'Kelola pengembalian alat yang dipinjam',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),

                // Daftar Pengembalian
                _buildReturnList(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReturnList(BuildContext context) {
    final List<Map<String, dynamic>> returns = [
      {
        'id': '#2',
        'name': 'Siti Nurhaliza',
        'item': 'Proyektor Epson',
        'quantity': '12 unit',
        'borrowDate': '2024-03-10',
        'returnDate': '2024-03-12',
        'status': 'Disetujui',
        'statusColor': Colors.green.withOpacity(0.1),
        'statusTextColor': Colors.green,
        'lateDays': 683,
        'isLate': false,
      },
      {
        'id': '#4',
        'name': 'Budi Santoso',
        'item': 'Kamera DSLR Canon',
        'quantity': '1 unit',
        'borrowDate': '2024-03-01',
        'returnDate': '2024-03-05',
        'status': 'Terlambat',
        'statusColor': Colors.red.withOpacity(0.1),
        'statusTextColor': Colors.red,
        'lateDays': 690,
        'isLate': true,
      },
    ];

    return Column(
      children: List.generate(returns.length, (index) {
        final item = returns[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildReturnCard(
            context: context,
            id: item['id'],
            name: item['name'],
            item: item['item'],
            quantity: item['quantity'],
            borrowDate: item['borrowDate'],
            returnDate: item['returnDate'],
            status: item['status'],
            statusColor: item['statusColor'],
            statusTextColor: item['statusTextColor'],
            lateDays: item['lateDays'],
            isLate: item['isLate'],
          ),
        );
      }),
    );
  }

  Widget _buildReturnCard({
    required BuildContext context,
    required String id,
    required String name,
    required String item,
    required String quantity,
    required String borrowDate,
    required String returnDate,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
    required int lateDays,
    required bool isLate,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
            // Nama User (besar & tebal)
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),

            // Alat (warna abu-abu, ukuran sedang)
            Text(
              item,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),

            // Detail Peminjaman (dengan ikon kecil)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.inventory, 'Jumlah', quantity),
                _buildDetailRow(Icons.calendar_today, 'Tanggal Pinjam', borrowDate),
                _buildDetailRow(Icons.calendar_today, 'Tanggal Kembali', returnDate),
              ],
            ),
            const SizedBox(height: 16),

            // Info Terlambat (jika ada)
            if (isLate)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_outlined, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'Terlambat $lateDays hari',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Tombol Konfirmasi (lebih besar, hijau solid)
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pengembalian $name telah dikonfirmasi')),
                );
              },
              icon: const Icon(Icons.check_circle, size: 20),
              label: const Text('Konfirmasi Pengembalian'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}