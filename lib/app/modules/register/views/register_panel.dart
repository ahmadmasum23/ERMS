import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';
import 'package:inven/app/global/widgets/CustomBtnForm.dart';
import 'package:inven/app/modules/register/controllers/register_controller.dart';
import 'package:inven/app/routes/app_pages.dart';

class RegisterPanel extends GetView<RegisterController> {
  const RegisterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppbar(title: 'Konfigurasi', boldTitle: 'Aplikasi', showNotif: false),

        Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade50,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              const Text(
                'Sistem Peminjaman Alat untuk Jurusan Tata Busana',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                'Minta Admin Untuk Menambhakan Anda sebagai User\n'
                'Tidak memerlukan konfigurasi URL API.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 25),

              CustomBtnForm(
                label: 'Lanjut ke Login',
                OnPress: () {
                  Get.snackbar('Info', 'Mengarahkan ke halaman login...');
                  Get.offAllNamed(Routes.LOGIN);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}