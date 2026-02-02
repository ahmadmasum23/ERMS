import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/modules/borrower/controllers/borrower_controller.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';

class BorrowerProfileView extends GetView<BorrowerController> {
  const BorrowerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // AppBar kustom
          CustomAppbar(
            onTitleTap: () async {
              final result = await showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(0, 60, 0, 0),
                items: const [
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ],
              );
              if (result == 'logout') {
                _showLogoutDialog();
              }
            },
            title: 'Hallo',
            boldTitle: controller.userData?.namaLengkap ?? '',
          ),

          // Konten profile
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _buildInfoCard(
                title: 'Personal Information',
                icon: Icons.person,
                content: Column(
                  children: [
                    _buildPersonalInfo(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card untuk info user
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget content,
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
            // Header
            Row(
              children: [
                Icon(icon, color: Colors.black, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Konten
            content,
          ],
        ),
      ),
    );
  }

  /// Info user
Widget _buildPersonalInfo() {
  final user = controller.userData;

  return Column(
    children: [
      _buildInfoRow('Full Name', user?.namaLengkap ?? '-'),
      const Divider(height: 24),
      _buildInfoRow('Phone', user?.nomorHp ?? '-'), // Nomor HP
      const Divider(height: 24),
      _buildInfoRow('Address', user?.alamat ?? '-'), // Alamat
      const Divider(height: 24),
      _buildInfoRow('Member Since', user?.dibuatPada != null 
        ? '${user!.dibuatPada!.day}-${user.dibuatPada!.month}-${user.dibuatPada!.year}' 
        : '-'), // Tanggal bergabung
    ],
  );
}

  /// Row info label & value
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  /// Tombol edit & logout
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Get.snackbar('Edit Profile', 'Fitur edit profile segera hadir');
            },
            icon: const Icon(Icons.edit, size: 20),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: const BorderSide(color: Colors.black),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.logout, size: 20),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Dialog logout
  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout?', style: TextStyle(fontSize: 18)),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.doLogout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
