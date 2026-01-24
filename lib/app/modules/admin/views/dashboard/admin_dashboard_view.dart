import 'package:flutter/material.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';

class AdminDashboardView extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AdminDashboardView({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppbar(
          title: 'Dashboard',
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
                // Header Dashboard Overview
                Text(
                  'Dashboard Overview',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selamat datang di Admin Panel Sistem Peminjaman Alat',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),

                // Statistik Utama (2x2 grid)
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.people_outline,
                        title: 'Total Users',
                        value: '5',
                        iconColor: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.build_outlined,
                        title: 'Total Alat',
                        value: '39',
                        iconColor: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.assignment_turned_in_outlined,
                        title: 'Total Peminjaman',
                        value: '5',
                        iconColor: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.warning_amber_outlined,
                        title: 'Pending Approval',
                        value: '2',
                        iconColor: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Status Alat
                Text(
                  'Status Alat',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.check_circle,
                        title: 'Alat Tersedia',
                        value: '27',
                        iconColor: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.trending_up,
                        title: 'Sedang Dipinjam',
                        value: '2',
                        iconColor: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Peminjaman Terbaru — sekarang setiap item jadi card terpisah
                Text(
                  'Peminjaman Terbaru',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLoanItem('Budi Santoso', 'Laptop Asus ROG', 'Pending'),
                const SizedBox(height: 8),
                _buildLoanItem('Siti Nurhaliza', 'Proyektor Epson', 'Disetujui'),
                const SizedBox(height: 8),
                _buildLoanItem('Ahmad Dahlan', 'Bola Sepak', 'Dikembalikan'),
                const SizedBox(height: 8),
                _buildLoanItem('Budi Santoso', 'Kamera DSLR Canon', 'Terlambat'),
                const SizedBox(height: 8),
                _buildLoanItem('Siti Nurhaliza', 'Microphone Wireless', 'Pending'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Card statistik utama — untuk angka
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
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
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Item daftar peminjaman — sekarang jadi card individual
  Widget _buildLoanItem(String name, String item, String status) {
    Color chipColor = Colors.grey;
    if (status == 'Pending') chipColor = Colors.amber.shade50;
    if (status == 'Disetujui') chipColor = Colors.green.shade100;
    if (status == 'Dikembalikan') chipColor = Colors.blue.shade100;
    if (status == 'Terlambat') chipColor = Colors.red.shade100;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xffF4F7F7),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    item,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Chip(
              label: Text(
                status,
                style: const TextStyle(color: Colors.black, fontSize: 10),
              ),
              backgroundColor: chipColor,
              side: BorderSide(color: chipColor),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 