  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import '../../../data/models/AppAlat.dart';
  import '../../../data/models/AppKategori.dart';
  import '../../../data/services/alat_service.dart';

  class AdminAlatController extends GetxController {
    final AlatService _alatService = AlatService();

    var alatList = <AppAlat>[].obs;
    var filteredAlatList = <AppAlat>[].obs;
    var kategoriOptions = <AppKategori>[].obs;
    var isLoading = false.obs;
    var selectedKategoriFilter = 0.obs; // 0 = all categories
    
    final TextEditingController searchController = TextEditingController();

    @override
    void onInit() {
      super.onInit()  ;
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
        final alat = await _alatService.getAllAlat  ();
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
      String? urlGambar,
      int stok = 1,
      String? kodeAlat,
      String status = 'tersedia',
    }) async {
      try {
        isLoading.value = true;
        
        final newAlat = await _alatService.createAlat(
          nama: nama,
          kategoriId: kategoriId,
          kondisi: kondisi,
          urlGambar: urlGambar,
          stok: stok,
          kodeAlat: kodeAlat,
          status: status,
        );
        
        alatList.add(newAlat);
        filterAlat(); // Refresh filter
        
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
      }
    }

    Future<bool> updateAlat({
      required int id,
      String? nama,
      int? kategoriId,
      String? kondisi,
      String? urlGambar,
      int? stok,
      String? kodeAlat,
      String? status,
    }) async {
      try {
        isLoading.value = true;
        
        final success = await _alatService.updateAlat(
          id: id,
          nama: nama,
          kategoriId: kategoriId,
          kondisi: kondisi,
          urlGambar: urlGambar,
          stok: stok,
          kodeAlat: kodeAlat,
          status: status,
        );
        
        if (success) {
          await fetchAlat(); // Refresh the list
      
          Get.snackbar(
            "✓ Berhasil",
            "Alat berhasil diperbarui",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade900,
          );
      
          return true;
        }
        return false;
      } catch (e) {
        print("ERROR UPDATE ALAT: $e");
        Get.snackbar(
          "✗ Gagal",
          "Gagal memperbarui alat: ${e.toString()}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade900,
        );
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
      List<AppAlat> filtered = [...alatList];
      
      // Filter by search term
      if (searchController.text.isNotEmpty) {
        final searchTerm = searchController.text.toLowerCase();
        filtered = filtered.where((alat) => 
          alat.nama.toLowerCase().contains(searchTerm)
        ).toList();
      }
      
      // Filter by category
      if (selectedKategoriFilter.value != 0) {
        filtered = filtered.where((alat) => 
          alat.kategoriId == selectedKategoriFilter.value
        ).toList();
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

    List<AppAlat> getAlatByKondisi(String kondisi) {
      return alatList.where((alat) => alat.kondisi == kondisi).toList();
    }

    int getTotalAlatCount() => alatList.length;
    int getBaikCount() => getAlatByKondisi('baik').length;
    int getRusakRinganCount() => getAlatByKondisi('rusak_ringan').length;
    int getRusakBeratCount() => getAlatByKondisi('rusak_berat').length;
  }