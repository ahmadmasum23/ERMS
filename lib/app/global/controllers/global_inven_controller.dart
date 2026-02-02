import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:inven/app/data/models/Alat.dart';
import 'package:inven/app/data/services/alat_service.dart';
import 'package:inven/app/data/services/auth_service.dart';

class GlobalInvenController extends GetxController {
  // Service untuk database operations
  final AlatService _alatService = AlatService();
  
  //controller untuk input teks dari TextField
  final ctrlFilter = TextEditingController();

  //proerti untuk handling interaksi user
  final fcsFilter = FocusNode();

  //nilai kategori yang akan dipilih user (default saat ini 0)
  var selectOpsi = 0.obs;

  Rx<Map<int, String>> opsiFilter = Rx({});

  //indikator loading (true == load dan false == idle)
  var isLoading = false.obs;

  //data barang yang difilter
  var filterBarang = <Alat>[].obs;

  //data seluruh barang dari database
  var barang = <Alat>[].obs;

  //timer untuk penunda eksekusi fungsi filter (combineFilter())
  Timer? _debounce;

  //penanda untuk data sudah fetch atau belum
  bool _hasFetch = false;

  @override
  void onInit() {
    print('DEBUG: GlobalInvenController onInit called');
    super.onInit();
    // Don't fetch data immediately on init
    // Data will be fetched when user logs in or when needed
    print('DEBUG: GlobalInvenController initialized, waiting for user authentication');
  }

  @override
  void onClose() {
    ctrlFilter.dispose();
    fcsFilter.dispose();
    super.onClose();
  }

  Future<void> refresh() async {
    isLoading.value = true;

    await Future.delayed(Duration(seconds: 1));

    await fetchData(isRefresh: true);

    await Future.delayed(Duration(seconds: 2));

    isLoading.value = false;
  }

  Future<void> fetchData({bool isRefresh = false}) async {
    print('DEBUG: GlobalInvenController fetchData called, isRefresh: $isRefresh');
    if (barang.isNotEmpty && !isRefresh) {
      print('DEBUG: GlobalInvenController data already exists, returning');
      return;
    }

    // Check if user is authenticated
    final authService = AuthService();
    if (!authService.isLoggedIn) {
      print('DEBUG: User not authenticated, skipping data fetch');
      return;
    }

    try {
      print('DEBUG: GlobalInvenController starting data fetch');
      isLoading.value = true;

      print('DEBUG: GlobalInvenController calling AlatService.getAllAlat()');
      List<Alat> item = await _alatService.getAllAlat();
      print('DEBUG: GlobalInvenController getAllAlat returned ${item.length} items');

      barang.assignAll(item);
      print('DEBUG: GlobalInvenController barang assigned');

      filterBarang.assignAll(item);
      print('DEBUG: GlobalInvenController filterBarang assigned');

      opsiFilter.value = {
        0: "|||",
        for (var alat in item)
          if (alat.kategori != null)
            alat.kategori!.id: alat.kategori!.nama,
      };
      print('DEBUG: GlobalInvenController opsiFilter assigned');
    } catch (e) {
      print('DEBUG: GlobalInvenController fetchData error: $e');
      print(e);
      Get.snackbar('error', 'Terjadi kesalahan: $e');
    } finally {
      print('DEBUG: GlobalInvenController fetchData finished');
      isLoading.value = false;
    }
  }

  void combineFilter() {
    ///mengambil teks dari input pengguna
    ///lalu mengubahnya menjadi huruf kecil (.toLowerCase()) untuk menghindari case sensitif
    String keyword = ctrlFilter.text.toLowerCase();

    ///mengambil nilai chip melalui pilihan user
    int select = selectOpsi.value;

    ///mengambil seluruh data barang (semua data barang tanpa filter)
    ///data barang nantinya akan difilter dengan berbagai kondisi
    List<Alat> item = barang;

    ///tahap 1 filter barang
    ///tahap ini memfilter barang berdasarkam input pengguna (TextField)
    if (keyword.isNotEmpty) {
      ///hanya mengembalikan data barang dengan beberapa kondisi
      item = item.where((alat) {
        ///"alat.nama" berdasarkan nama alat
        return alat.nama.toLowerCase().contains(keyword) ||
            ///"alat.kategori!.nama" berdasarkan kategori alat
            (alat.kategori?.nama.toLowerCase().contains(keyword) ?? false) ||
            ///"alat.kodeAlat" berdasarkan kode alat
            (alat.kodeAlat?.toLowerCase().contains(keyword) ?? false);
      }).toList();
    }

    ///tahap 2 filter barang
    ///tahap ini memfilter barang berdasarkan pilihan pengguna (CustomFilterChips)
    if (select != 0) {
      ///hanya mengembalikan data barang dengan 1 kondisi (by kategori_id)
      item = item.where((alat) {
        return alat.kategoriId == select;
      }).toList();
    }

    ///update state hasil filter
    ///"filterBarang" akan mengisi data yang sudah difilter ".assignAll(item)"
    filterBarang.assignAll(item);
  }

  ///fungsi untuk stop filter pencarian by input (TextField)
  void filterData(String query) {
    ///_debounce?.isActive ?? false maksudnya
    ///Kalau _debounce ada dan aktif -> true
    ///Kalau _debounce ada tapi sudah selesai -> false
    ///Kalau _debounce masih null (belum pernah dibuat) -> false
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    ///bikin timer baru yang jalan sekali abis 300ms
    _debounce = Timer(Duration(milliseconds: 300), () {
      ///kalau 300ms lewat combineFilter(); bakal dieksekusi
      combineFilter();
    });
  }

  // Method untuk mencari alat berdasarkan nama
  Future<List<Alat>> searchAlat(String searchTerm) async {
    try {
      return await _alatService.searchAlat(searchTerm);
    } catch (e) {
      print('ERROR SEARCH ALAT: $e');
      return [];
    }
  }

  // Method untuk mendapatkan alat berdasarkan kategori
  Future<List<Alat>> getAlatByKategori(int kategoriId) async {
    try {
      return await _alatService.getAlatByKategori(kategoriId);
    } catch (e) {
      print('ERROR GET ALAT BY KATEGORI: $e');
      return [];
    }
  }

  // Method untuk mendapatkan opsi kategori
  Future<List<Map<String, dynamic>>> getKategoriOptions() async {
    try {
      final kategoriList = await _alatService.getKategoriOptions();
      return kategoriList
          .map((kategori) => {
                'id': kategori.id,
                'nama': kategori.nama,
              })
          .toList();
    } catch (e) {
      print('ERROR GET KATEGORI OPTIONS: $e');
      return [];
    }
  }
}
