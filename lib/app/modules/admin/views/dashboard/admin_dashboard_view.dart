import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';
import 'package:inven/app/modules/admin/controllers/admin_alat_controller.dart';
import 'package:inven/app/modules/admin/controllers/admin_kategori_controller.dart';
// Removed import to deleted admin_user_management_view.dart

class AdminDashboardView extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  // Tambahkan controller
  final AdminAlatController alatController = Get.put(AdminAlatController());
  final AdminKategoriController kategoriController = Get.put(AdminKategoriController());

  AdminDashboardView({Key? key, required this.scaffoldKey}) : super(key: key);

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

                // Statistik Utama
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.assignment_turned_in_outlined,
                        title: 'Total Peminjaman',
                        value: '0', // nanti bisa diambil dari tabel peminjaman,
                        iconColor: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.build_outlined,
                        title: 'Total Alat',
                        value: alatController.getTotalAlatCount().toString(),
                        iconColor: Colors.black,
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 12),
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.category_outlined,
                        title: 'Jumlah Kategori Alat',
                        value: kategoriController.kategoriList.length.toString(),
                        iconColor: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.assignment_turned_in_outlined,
                        title: 'Total Peminjaman',
                        value: '0', // nanti bisa diambil dari tabel peminjaman
                        iconColor: Colors.black,
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 24),

                // Status Alat
                Text(
                  'Status Alat',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.check_circle,
                        title: 'Alat Tersedia',
                        value: alatController.getBaikCount().toString(),
                        iconColor: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.trending_up,
                        title: 'Sedang Dipinjam',
                        value: '0', // nanti bisa diambil dari status peminjaman
                        iconColor: Colors.black,
                      ),
                    ),
                  ],
                )),
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
} 