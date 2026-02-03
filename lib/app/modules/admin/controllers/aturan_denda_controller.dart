import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/AturanDenda.dart';

class AturanDendaController extends GetxController {
  final jenisController = ''.obs;
  final jumlahController = TextEditingController();
  final keteranganController = TextEditingController();

  final List<String> jenisOptions = ['terlambat', 'rusak', 'hilang'];
  var listAturan = <AturanDenda>[].obs;

  void tambahAturan() {
    if (jenisController.value.isEmpty || jumlahController.text.isEmpty) {
      Get.snackbar('Error', 'Jenis & jumlah wajib diisi');
      return;
    }

    final jumlah = num.tryParse(jumlahController.text);
    if (jumlah == null) {
      Get.snackbar('Error', 'Jumlah harus angka');
      return;
    }

    listAturan.add(
      AturanDenda(
        id: DateTime.now().millisecondsSinceEpoch,
        jenis: jenisController.value,
        jumlah: jumlah,
        keterangan:
            keteranganController.text.isEmpty ? null : keteranganController.text,
      ),
    );

    resetForm();
  }

  void resetForm() {
    jenisController.value = '';
    jumlahController.clear();
    keteranganController.clear();
  }

  @override
  void onClose() {
    jumlahController.dispose();
    keteranganController.dispose();
    super.onClose();
  }
}
