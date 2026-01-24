import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';
import 'package:inven/app/modules/operator/controllers/operator_controller.dart';

class OperatorProfileView extends GetView<OperatorController> {
  const OperatorProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppbar(
            title: 'Profile',
            boldTitle: controller.userData?.nama ?? '',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
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
                      /// HEADER
                      Row(
                        children: const [
                          Icon(Icons.person, size: 24, color: Colors.black),
                          SizedBox(width: 12),
                          Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// CONTENT
                      Column(
                        children: [
                          _infoRow(
                            'Full Name',
                            controller.userData?.nama ?? '-',
                          ),
                          const Divider(height: 24),
                          _infoRow(
                            'Email',
                            controller.userData?.email ?? '-',
                          ),
                          const Divider(height: 24),
                          _infoRow(
                            'Institution',
                            controller.userData?.inst ?? '-',
                          ),
                          const Divider(height: 24),
                          _infoRow(
                            'Member Since',
                            'January 2024',
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// ACTION BUTTONS
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.snackbar(
                                  'Edit Profile',
                                  'Edit profile feature coming soon',
                                );
                              },
                              icon: const Icon(Icons.edit, size: 20),
                              label: const Text('Edit Profile'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side:
                                      const BorderSide(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.dialog(
                                  AlertDialog(
                                    title: const Text(
                                      'Logout?',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    content: const Text(
                                      'Apakah kamu yakin ingin keluar?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        child: const Text(
                                          'Batal',
                                          style:
                                              TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Get.back();
                                          controller.doLogout();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                        ),
                                        child: const Text(
                                          'Logout',
                                          style:
                                              TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.logout, size: 20),
                              label: const Text('Logout'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
