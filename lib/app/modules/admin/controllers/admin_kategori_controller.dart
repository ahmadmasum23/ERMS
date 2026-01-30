import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/AppKategori.dart';
import '../../../data/services/kategori_service.dart';

class AdminKategoriController extends GetxController {
  final KategoriService _kategoriService = KategoriService();

  var kategoriList = <AppKategori>[].obs;
  var isLoading = false.obs;
  var alatCountMap = <int, int>{}.obs;

  @override
  void onInit() {
    fetchKategori();
    super.onInit();
  }

  Future<void> fetchKategori() async {
    try {
      isLoading.value = true;
      
      final kategori = await _kategoriService.getAllKategori();
      kategoriList.value = kategori;
      
      // Fetch alat count for each kategori
      await _fetchAlatCounts();
      
    } catch (e) {
      kategoriList.clear();
      Get.snackbar(
        "Error",
        "Gagal mengambil data kategori",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      print("ERROR FETCH KATEGORI: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchAlatCounts() async {
    try {
      final Map<int, int> countMap = {};
      for (var kategori in kategoriList) {
        final count = await _kategoriService.getAlatCountByKategori(kategori.id);
        countMap[kategori.id] = count;
      }
      alatCountMap.value = countMap;
    } catch (e) {
      print("ERROR FETCH ALAT COUNTS: $e");
    }
  }

  Future<bool> addKategori({
    required String kode,
    required String nama,
  }) async {
    try {
      isLoading.value = true;
      
      final newKategori = await _kategoriService.createKategori(
        kode: kode,
        nama: nama,
      );
      
      kategoriList.add(newKategori);
      await _fetchAlatCounts();
      
      Get.snackbar(
        "✓ Berhasil",
        "Kategori berhasil ditambahkan",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
      );
      
      return true;
    } catch (e) {
      print("ERROR ADD KATEGORI: $e");
      Get.snackbar(
        "✗ Gagal",
        "Gagal menambahkan kategori: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateKategori({
    required int id,
    required String kode,
    required String nama,
  }) async {
    try {
      isLoading.value = true;
      
      final success = await _kategoriService.updateKategori(
        id: id,
        kode: kode,
        nama: nama,
      );
      
      if (success) {
        await fetchKategori(); // Refresh the list
        
        Get.snackbar(
          "✓ Berhasil",
          "Kategori berhasil diperbarui",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade900,
        );
        
        return true;
      }
      return false;
    } catch (e) {
      print("ERROR UPDATE KATEGORI: $e");
      Get.snackbar(
        "✗ Gagal",
        "Gagal memperbarui kategori: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteKategori(int id) async {
    try {
      isLoading.value = true;
      
      final success = await _kategoriService.deleteKategori(id);
      
      if (success) {
        kategoriList.removeWhere((kategori) => kategori.id == id);
        alatCountMap.remove(id);
        
        Get.snackbar(
          "✓ Berhasil",
          "Kategori berhasil dihapus",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade900,
        );
        
        return true;
      }
      return false;
    } catch (e) {
      print("ERROR DELETE KATEGORI: $e");
      Get.snackbar(
        "✗ Gagal",
        "Gagal menghapus kategori: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  int getAlatCount(int kategoriId) {
    return alatCountMap[kategoriId] ?? 0;
  }
}