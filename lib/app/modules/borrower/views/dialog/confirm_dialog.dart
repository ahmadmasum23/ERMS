import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/global/widgets/CustomBtnForm.dart';
import 'package:inven/app/modules/borrower/controllers/borrower_controller.dart';
import 'dialog_barang.dart';
import 'dialog_instansi.dart';
import 'dialog_keperluan.dart';
import 'dialog_pemohon.dart';
import 'dialog_tanggal.dart';
import 'dialog_unit.dart';

class ConfirmDialog extends GetView<BorrowerController> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Konfirmasi Pengajuan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: Colors.red.shade900),
                ),
              ],
            ),
            
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pastikan semua data sudah benar sebelum mengajukan peminjaman',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text(
              'Informasi peminjam',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: DialogPemohon()),

                const SizedBox(width: 10),

                Expanded(child: DialogInstansi()),
              ],
            ),

            const SizedBox(height: 10),

            DialogKeperluan(),

            const SizedBox(height: 15),

            Text(
              'Detail peminjaman (${controller.slctItemId.length} alat dipilih)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            DialogBarang(),

            const SizedBox(height: 10),

            DialogUnit(),

            const SizedBox(height: 10),

            DialogTanggal(),

            const SizedBox(height: 10),

            CustomBtnForm(
              label: 'Ajukan Peminjaman',
              isLoading: controller.isBtnLoad.value,
              OnPress: () {
                Get.back(); // Tutup dialog
                controller.pengajuan(); // Proses pengajuan
              },
            ),
          ],
        ),
      ),
    );
  }
}
