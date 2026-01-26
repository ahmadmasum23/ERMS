import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/data/models/AppBarang.dart';
import 'package:inven/app/global/controllers/global_user_controller.dart';
import 'package:inven/app/global/utils/Formatter.dart';
import 'package:inven/app/global/widgets/CustomShowDialog.dart';
import 'package:inven/app/modules/admin/controllers/admin_edit_controller.dart';
import 'package:inven/app/modules/admin/views/editdata/admin_edit_view.dart';

class DataAlat extends StatelessWidget {
  final AppBarang model;

  const DataAlat({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    // Add comprehensive null safety
    final barang = model.nmBarang;
    final merk = model.merk;
    final kode = model.kdBarang;
    final vendor = model.vendor;
    final garansi = model.garansi;
    final jenis = model.jenis?.jenis;
    final note = model.note;
    final desk = model.deskripsi;
    final sumber = model.sumBarang;
    final pengadaan = model.pengadaan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //nama barang dan tombol edit
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //nama barang
            Text(
              barang,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            // tombol untuk memunculkan edit data barang - hanya ditampilkan jika role adalah admin (peranId = 1)
            Obx(() {
              final userController = Get.find<GlobalUserController>();
              final currentUser = userController.user.value;
              
              // Tampilkan tombol edit hanya jika user saat ini adalah admin (role ID 1)
              if (currentUser != null && currentUser.peranId == 1) {
                return IconButton(
                  visualDensity: VisualDensity.comfortable,
                  onPressed: () {
                    // Put the controller before opening the dialog
                    Get.put(AdminEditController());
                    Get.dialog(
                      CustomShowDialog(
                        heightFactor: 0.70,
                        child: AdminEditView(model: model),
                      ),
                    ).then((_) {
                      // Clean up the controller when dialog is closed
                      if (Get.isRegistered<AdminEditController>()) {
                        Get.delete<AdminEditController>();
                      }
                    });
                  },
                  icon: Icon(Icons.edit, size: 20),
                );
              } else {
                // Jika bukan admin, tidak menampilkan tombol edit
                return Container(); // atau bisa juga menggunakan SizedBox.shrink()
              }
            }),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //merk barang
            Text(
              merk,
              style: const TextStyle(
                fontSize: 12,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),

            //kode barang
            Text(kode, style: const TextStyle(fontSize: 12, letterSpacing: 1)),
          ],
        ),

        const Divider(color: Colors.grey),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //vendor sumber barang
            Text(
              vendor,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),

            //badge garansi barang
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                border: Border.all(color: Colors.transparent),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                '${garansi.toString()} bulan',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        //jenis barang
        Row(
          children: [
            Text('Jenis: ', style: const TextStyle(fontSize: 12)),
            Text(
              jenis!,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 3),

        //catatan perawatan
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Catatan: ', style: const TextStyle(fontSize: 12)),
            Flexible(
              child: Text(
                note!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        //deskripsi  barang
        Container(
          padding: const EdgeInsets.all(8),
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deskripsi Barang:',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(desk!, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),

        const SizedBox(height: 5),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //sumber barang
            Text('$sumber ', style: TextStyle(fontSize: 12)),

            //tanggal pengadaan
            Text(
              Formatter.dateID(pengadaan),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
