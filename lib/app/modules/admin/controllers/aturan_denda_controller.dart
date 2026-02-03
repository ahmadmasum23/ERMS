import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/AturanDenda.dart';
import '../../../data/services/aturan_denda_service.dart';

class AturanDendaController extends GetxController {
  final AturanDendaService _service = AturanDendaService();

  final jenisController = ''.obs;
  final jumlahController = TextEditingController();
  final keteranganController = TextEditingController();

  final List<String> jenisOptions = ['terlambat', 'rusak', 'hilang'];

  var listAturan = <AturanDenda>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchAturan();
    super.onInit();
  }

  /// ================= GET DATA =================
  Future<void> fetchAturan() async {
    try {
      isLoading.value = true;
      final data = await _service.getAllAturan();
      listAturan.assignAll(data);
    } catch (e) {
       print("ERROR ATURAN DENDA: $e");
        Get.snackbar('Error', 'Gagal mengambil data aturan denda');
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= TAMBAH =================
  Future<void> tambahAturan() async {
    if (jenisController.value.isEmpty || jumlahController.text.isEmpty) {
      Get.snackbar('Error', 'Jenis & jumlah wajib diisi');
      return;
    }

    final jumlah = num.tryParse(jumlahController.text);
    if (jumlah == null) {
      Get.snackbar('Error', 'Jumlah harus angka');
      return;
    }

    try {
      isLoading.value = true;

      final data = AturanDenda(
        id: 0,
        jenis: jenisController.value,
        jumlah: jumlah,
        keterangan:
            keteranganController.text.isEmpty ? null : keteranganController.text,
      );

      await _service.insertAturan(data);
      await fetchAturan();
      resetForm();
      Get.back(); // tutup dialog
      Get.snackbar('Sukses', 'Aturan denda berhasil ditambahkan');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan data');
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= EDIT =================
  void isiFormDariData(AturanDenda data) {
    jenisController.value = data.jenis;
    jumlahController.text = data.jumlah.toString();
    keteranganController.text = data.keterangan ?? '';
  }

  Future<void> updateAturan(int id) async {
    final jumlah = num.tryParse(jumlahController.text);
    if (jumlah == null) {
      Get.snackbar('Error', 'Jumlah harus angka');
      return;
    }

    try {
      isLoading.value = true;

      final data = AturanDenda(
        id: id,
        jenis: jenisController.value,
        jumlah: jumlah,
        keterangan:
            keteranganController.text.isEmpty ? null : keteranganController.text,
      );

      await _service.updateAturan(data);
      await fetchAturan();
      resetForm();
      Get.back();
      Get.snackbar('Sukses', 'Aturan berhasil diperbarui');
    } catch (e) {
      Get.snackbar('Error', 'Gagal update data');
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= HAPUS =================
  Future<void> hapusAturan(int id) async {
    try {
      isLoading.value = true;
      await _service.deleteAturan(id);
      await fetchAturan();
      Get.snackbar('Sukses', 'Aturan berhasil dihapus');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus data');
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= RESET FORM =================
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
