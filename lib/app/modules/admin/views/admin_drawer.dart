import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/modules/admin/controllers/admin_controller.dart';

class AdminDrawer extends StatelessWidget {
  final AdminController controller;

  const AdminDrawer({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.settings, color: Colors.black),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Admin Panel',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Sistem Peminjaman',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(icon: Icons.dashboard, title: 'Dashboard', index: 0),
                _drawerItem(icon: Icons.people, title: 'User Management', index: 1),
                _drawerItem(icon: Icons.build, title: 'Alat Management', index: 2),
                _drawerItem(icon: Icons.category, title: 'Kategori Management', index: 3),
                _drawerItem(icon: Icons.assignment, title: 'Data Peminjaman', index: 4),
                _drawerItem(icon: Icons.refresh, title: 'Pengembalian', index: 5),
                _drawerItem(icon: Icons.show_chart, title: 'Activity Log', index: 6),
                _drawerItem(icon: Icons.person, title: 'Profile', index: 7),
                _drawerItem(icon: Icons.rule, title: 'Aturan Denda', index: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    return Obx(() => ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          color: controller.isIndex.value == index ? Colors.black : Colors.grey[700],
          fontWeight: controller.isIndex.value == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: controller.isIndex.value == index,
      selectedTileColor: Colors.grey[100],
      onTap: () {
        controller.changePage(index);
        Get.back(); // tutup drawer
      },
    ));
  }
}