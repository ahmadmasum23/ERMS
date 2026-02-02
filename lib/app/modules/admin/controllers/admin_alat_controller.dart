import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/Alat.dart';
import '../../../data/models/KategoriAlat.dart';
import '../../../data/services/alat_service.dart';

class AdminAlatController extends GetxController {
  final AlatService _alatService = AlatService();

  var alatList = <Alat>[].obs;
  var filteredAlatList = <Alat>[].obs;
  var kategoriOptions = <KategoriAlat>[].obs;
  var isLoading = false.obs;
  var selectedKategoriFilter = 0.obs; // 0 = all categories

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchAlat();
    fetchKategoriOptions();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchAlat() async {
    try {
      isLoading.value = true;
      final alat = await _alatService.getAllAlat();
      alatList.value = alat;
      filteredAlatList.value = alat;
    } catch (e) {
      alatList.clear();
      filteredAlatList.clear();
      Get.snackbar(
        "Error",
        "Gagal mengambil data alat",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      print("ERROR FETCH ALAT: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchKategoriOptions() async {
    try {
      final kategori = await _alatService.getKategoriOptions();
      kategoriOptions.value = kategori;
    } catch (e) {
      print("ERROR FETCH KATEGORI OPTIONS: $e");
    }
  }

  Future<bool> addAlat({
    required String nama,
    int? kategoriId,
    required String kondisi,
    int stok = 1,
    String? kodeAlat,
    String status = 'tersedia',
    dynamic imageFile, // ⬅️ GANTI JADI dynamic untuk menerima File atau XFile
  }) async {
    try {
      print('DEBUG: Starting addAlat function');
      print('DEBUG: Parameters received - nama: $nama, kategoriId: $kategoriId, kondisi: $kondisi, stok: $stok, kodeAlat: $kodeAlat, status: $status, imageFile type: ${imageFile?.runtimeType}');
      
      isLoading.value = true;

      String? imageUrl;

      // 🔥 1. UPLOAD GAMBAR DULU JIKA ADA
      if (imageFile != null) {
        print('DEBUG: Attempting to upload image file: ${imageFile is File ? imageFile.path : imageFile.name}');
        imageUrl = await _alatService.uploadImage(imageFile);
        print('DEBUG: Image uploaded successfully, URL: $imageUrl');
      } else {
        print('DEBUG: No image file provided, skipping upload');
      }

      // 🔥 2. SIMPAN DATA + URL KE DATABASE
      print('DEBUG: Attempting to create alat in database');
      final newAlat = await _alatService.createAlat(
        nama: nama,
        kategoriId: kategoriId,
        kondisi: kondisi,
        urlGambar: imageUrl, // ⬅️ URL MASUK KE KOLOM url_gambar
        stok: stok,
        kodeAlat: kodeAlat,
        status: status,
      );
      print('DEBUG: Alat created successfully with ID: ${newAlat.id}');

      alatList.add(newAlat);
      filterAlat();

      Get.snackbar(
        "✓ Berhasil",
        "Alat berhasil ditambahkan",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
      );

      return true;
    } catch (e) {
      print("ERROR ADD ALAT: $e");
      print("ERROR TYPE: ${e.runtimeType}");
      
      // Coba cetak detail error jika memungkinkan
      if (e is Exception) {
        print("ERROR DETAILS: ${e.toString()}");
      }
      
      Get.snackbar(
        "✗ Gagal",
        "Gagal menambahkan alat: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isLoading.value = false;
      print('DEBUG: Finished addAlat function, isLoading: ${isLoading.value}');
    }
  }

  Future<bool> updateAlat({
    required int id,
    String? nama,
    int? kategoriId,
    String? kondisi,
    int? stok,
    String? kodeAlat,
    String? status,
    dynamic imageFile, // ⬅️ GANTI JADI dynamic
  }) async {
    try {
      isLoading.value = true;

      String? imageUrl;

      // 🔥 Upload gambar baru kalau ada
      if (imageFile != null) {
        print('DEBUG: Updating alat ID: $id, uploading new image');
        imageUrl = await _alatService.uploadImage(imageFile);
        print('DEBUG: New image uploaded, URL: $imageUrl');
      }

      final success = await _alatService.updateAlat(
        id: id,
        nama: nama,
        kategoriId: kategoriId,
        kondisi: kondisi,
        urlGambar: imageUrl,
        stok: stok,
        kodeAlat: kodeAlat,
        status: status,
      );

      if (success) {
        await fetchAlat();

        Get.snackbar(
          "✓ Berhasil",
          "Alat berhasil diperbarui",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade900,
        );
      }

      return success;
    } catch (e) {
      print("ERROR UPDATE ALAT: $e");
      print("ERROR TYPE: ${e.runtimeType}");
      if (e is Exception) {
        print("ERROR DETAILS: ${e.toString()}");
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteAlat(int id) async {
    try {
      isLoading.value = true;

      final success = await _alatService.deleteAlat(id);

      if (success) {
        alatList.removeWhere((alat) => alat.id == id);
        filterAlat(); // Refresh filter

        Get.snackbar(
          "✓ Berhasil",
          "Alat berhasil dihapus",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade900,
        );

        return true;
      }
      return false;
    } catch (e) {
      print("ERROR DELETE ALAT: $e");
      Get.snackbar(
        "✗ Gagal",
        "Gagal menghapus alat: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void filterAlat() {
    List<Alat> filtered = [...alatList];

    // Filter by search term
    if (searchController.text.isNotEmpty) {
      final searchTerm = searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (alat) => (alat.nama?.toLowerCase().contains(searchTerm) ?? false),
          )
          .toList();
    }

    // Filter by category
    if (selectedKategoriFilter.value != 0) {
      filtered = filtered
          .where((alat) => alat.kategoriId == selectedKategoriFilter.value)
          .toList();
    }

    filteredAlatList.value = filtered;
  }

  void onSearchChanged(String value) {
    filterAlat();
  }

  void onKategoriFilterChanged(int kategoriId) {
    selectedKategoriFilter.value = kategoriId;
    filterAlat();
  }

  List<Alat> getAlatByKondisi(String kondisi) {
    return alatList.where((alat) => alat.kondisi == kondisi).toList();
  }

  int getTotalAlatCount() => alatList.length;
  int getBaikCount() => getAlatByKondisi('baik').length;
  int getRusakRinganCount() => getAlatByKondisi('rusak_ringan').length;
  int getRusakBeratCount() => getAlatByKondisi('rusak_berat').length;
}
