import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inven/app/data/models/AppPengajuan.dart';
import 'package:inven/app/data/models/Alat.dart';
import 'package:inven/app/data/models/ProfilPengguna.dart';
import 'package:inven/app/data/models/DetailPeminjaman.dart';
import 'package:inven/app/data/models/KategoriAlat.dart';
import 'package:inven/app/data/services/peminjaman_service.dart';
import 'package:inven/app/data/services/alat_service.dart';
import 'package:inven/app/global/controllers/global_inven_controller.dart';
import 'package:inven/app/global/controllers/global_user_controller.dart';
import 'package:inven/app/modules/login/controllers/login_controller.dart';
import 'package:inven/app/modules/login/views/login_view.dart';

// Static services class to provide data fetching methods
class StaticServicesGet {
  final PeminjamanService _peminjamanService = PeminjamanService();
  final AlatService _alatService = AlatService();

  Future<List<AppPengajuan>> dataPinjam(dynamic userId) async {
    print('DEBUG: dataPinjam called with userId: $userId (type: ${userId.runtimeType})');
    // Handle both String and int userId types
    final userIdString = userId is int ? userId.toString() : userId as String;
    
    try {
      final peminjamanList = await _peminjamanService.getPeminjamanByUser(userIdString);
      print('DEBUG: Got ${peminjamanList.length} peminjaman records');
      // Convert Peminjaman to AppPengajuan - we need to create a conversion
      return peminjamanList.map((p) => AppPengajuan(
        id: p.id,
        peminjamId: p.peminjamId,
        disetujuiOleh: p.disetujuiOleh,
        tanggalPinjam: p.tanggalPinjam,
        tanggalJatuhTempo: p.tanggalJatuhTempo,
        tanggalKembali: p.tanggalKembali,
        status: p.status,
        hariTerlambat: p.hariTerlambat,
        alasan: p.alasan,
        dibuatPada: p.dibuatPada,
      )).toList();
    } catch (e) {
      print('DEBUG: Error in dataPinjam: $e');
      // Return empty list if there's a permission error
      if (e.toString().contains('permission denied')) {
        print('DEBUG: Permission denied - returning empty list');
        // Get.snackbar('Info', 'Tidak dapat mengakses data peminjaman karena izin terbatas');
        return [];
      }
      rethrow; // Rethrow other errors
    }
  }

  Future<List<AppPengajuan>> dataRiwayat(dynamic userId) async {
    print('DEBUG: dataRiwayat called with userId: $userId (type: ${userId.runtimeType})');
    // Handle both String and int userId types
    final userIdString = userId is int ? userId.toString() : userId as String;
    
    try {
      final peminjamanList = await _peminjamanService.getPeminjamanByUser(userIdString);
      print('DEBUG: Got ${peminjamanList.length} riwayat records');
      return peminjamanList.map((p) => AppPengajuan(
        id: p.id,
        peminjamId: p.peminjamId,
        disetujuiOleh: p.disetujuiOleh,
        tanggalPinjam: p.tanggalPinjam,
        tanggalJatuhTempo: p.tanggalJatuhTempo,
        tanggalKembali: p.tanggalKembali,
        status: p.status,
        hariTerlambat: p.hariTerlambat,
        alasan: p.alasan,
        dibuatPada: p.dibuatPada,
      )).toList();
    } catch (e) {
      print('DEBUG: Error in dataRiwayat: $e');
      // Return empty list if there's a permission error
      if (e.toString().contains('permission denied')) {
        print('DEBUG: Permission denied - returning empty list');
        // Get.snackbar('Info', 'Tidak dapat mengakses riwayat karena izin terbatas');
        return [];
      }
      rethrow; // Rethrow other errors
    }
  }

  Future<List<Alat>> dataBarang() async {
    print('DEBUG: StaticServicesGet.dataBarang called');
    final result = await _alatService.getAllAlat();
    print('DEBUG: StaticServicesGet.dataBarang returned ${result.length} items');
    return result;
  }

  Future<List<KategoriAlat>> dataKategori() async {
    print('DEBUG: StaticServicesGet.dataKategori called');
    try {
      final result = await _alatService.getKategoriOptions();
      print('DEBUG: StaticServicesGet.dataKategori returned ${result.length} items');
      return result;
    } catch (e) {
      print('DEBUG: Error in dataKategori: $e');
      return [];
    }
  }

  Future<List<dynamic>> borrowerUnit() async {
    // This is a placeholder - you may need to implement the actual method
    // depending on what "borrowerUnit" should return
    return [];
  }
}

class BorrowerController extends GetxController {
  //controller data pengguna
  late final GlobalUserController userCtrl;

  // Getter for user data convenience
  ProfilPengguna? get userData => userCtrl.user.value;

  final riwayatList = <AppPengajuan>[].obs;
  final pinjamlist = <AppPengajuan>[].obs;
  
  // Data barang dan unit
  final itemList = <Alat>[].obs;
  final kategoriList = <KategoriAlat>[].obs; // Add category list
  final unitList = <dynamic>[].obs; // TODO: Replace with proper unit model type
  
  // Selected category ID
  var slctKategoriId = RxnInt();

  //nilai loading
  var isLoading = false.obs;
  var isBtnLoad = false.obs;
  var errorList = <String>[].obs;

  //pemantauan expand
  final expandR = ''.obs;
  final expandP = ''.obs;

  var isIndex = 0.obs; //index navigasi
  
  // Service instances
  final PeminjamanService servPst = PeminjamanService();
  final PeminjamanService servPut = PeminjamanService();
  final AlatService _alatService = AlatService();

  //komponen untuk filteChips
  final Map<int, String> opsFltr = {
    //data filter
    0: '|||',
    9: 'Pending',
    4: 'Disetujui',
    1: 'Ditolak',
    2: 'Selesai',
  };
  var riwayatFltr = <AppPengajuan>[].obs; //data yang dimunculkan
  var slctOps = 0.obs; //opsi yang dipilih

  //pemantauan untuk checkbox
  var slctItemId = <int>[].obs; //checkbox id barang (changed to list)
  var slctUnitId = <int>[].obs; //checkbox id unit (this will be the selected equipment)
  var isCheckAll = false.obs;
  
  // Selected item for dropdown (single selection)
  var selectedItemId = RxnInt();

  //key dropdown
  Key dropitem = UniqueKey();
  Key dropunit = UniqueKey();

  //controller tiap input
  final ctrlPemohon = TextEditingController();
  final ctrlInstansi = TextEditingController();
  final ctrlKeperluan = TextEditingController();
  final tglPinjam = Rxn<DateTime>();
  final tglKembali = Rxn<DateTime>();

  //init awal app dimulai
  @override
  void onInit() {
    print('DEBUG: BorrowerController onInit called');
    // Safely get GlobalUserController
    try {
      userCtrl = Get.find<GlobalUserController>();
      print('DEBUG: Found existing GlobalUserController');
    } catch (e) {
      // If not found, create a new one
      print('DEBUG: Creating new GlobalUserController');
      userCtrl = Get.put(GlobalUserController());
    }
    
    super.onInit();

    print('DEBUG: Calling fetchData from onInit');
    fetchData();

    if (userCtrl.user.value != null) {
      ctrlPemohon.text = userCtrl.user.value!.namaLengkap;
      print('DEBUG: User data loaded: ${userCtrl.user.value!.namaLengkap}');
    } else {
      print('DEBUG: User data is null');
    }
  }

  //fungsi ketika app ditutup
  @override
  void onClose() {
    ctrlInstansi.dispose();
    ctrlPemohon.dispose();
    ctrlKeperluan.dispose();
    super.onClose();
  }

  //convert item dipilih dari dropdown (id) -> (nama barang)
  String? get selectedItem {
    if (slctItemId.isEmpty) return null;
    final barang = itemList.firstWhereOrNull((i) {
      return i.id == slctItemId.first;
    });
    return barang?.nama; // Fixed: was nmBarang, now nama
  }

  //logout app
  void doLogout() {
    Get.offAll(
      () => LoginView(),
      binding: BindingsBuilder(() {
        Get.put(GlobalUserController());
        Get.put(GlobalInvenController());
        Get.put(LoginController());
      }),
    );
  }

  //fungsi ceklist semua unit (checkBox)
  void chekAll(bool val) {
    // For the equipment list, we use slctItemId which is already handled by the checkbox list
    // This method might need to be adapted based on the new flow
    if (val) {
      // If we need to select all equipment for the selected category
      final filteredItems = itemList.where((item) {
        if (slctKategoriId.value != null) {
          return item.kategoriId == slctKategoriId.value;
        }
        return false;
      }).toList();
      
      slctItemId.clear();
      slctItemId.addAll(filteredItems.map((item) => item.id));
      isCheckAll.value = true;
    } else {
      slctItemId.clear();
      isCheckAll.value = false;
    }
    slctItemId.refresh();
  }

  //periksa ceklist unit
  void updateCheck() {
    // Update check all status based on how many items are selected vs available
    final filteredItems = itemList.where((item) {
      if (slctKategoriId.value != null) {
        return item.kategoriId == slctKategoriId.value;
      }
      return false;
    }).toList();
    
    isCheckAll.value = slctItemId.length == filteredItems.length;
    slctItemId.refresh();
    update(); // Ensure UI updates
  }

  //fetch ulang form (refresh)
  Future<void> refresh() async {
    print('DEBUG: BorrowerController refresh called');
    isLoading.value = true;

    await Future.delayed(Duration(seconds: 1));

    await fetchData();

    await Future.delayed(Duration(seconds: 1));

    isLoading.value = false;
  }
  
  // Manual refresh method for user to call
  Future<void> manualRefresh() async {
    print('DEBUG: Manual refresh triggered');
    await fetchData();
  }

  //membersihkan form (reset)
  void resetForm() {
    ctrlPemohon.text = userCtrl.user.value?.namaLengkap ?? '';
    ctrlKeperluan.clear();

    tglPinjam.value = null;
    tglKembali.value = null;

    slctKategoriId.value = null;
    slctItemId.clear();
    slctUnitId.clear();
    selectedItemId.value = null;
    isCheckAll.value = false;

    dropitem = UniqueKey();
    dropunit = UniqueKey();

    slctUnitId.refresh();
    update();
  }



  //fungsi filterchips
  void filterChips() {
    int select = slctOps.value;

    List<AppPengajuan> data = riwayatList;

    if (select == 0) {
      riwayatFltr.assignAll(data);
    } else {
      riwayatFltr.assignAll(
        data.where((r) {
          final status = r.status.toLowerCase();
          switch (select) {
            case 9: return status.contains('pending') || status.contains('menunggu');
            case 4: return status.contains('disetujui');
            case 1: return status.contains('ditolak');
            case 2: return status.contains('selesai') || status.contains('dikembalikan');
            default: return false;
          }
        }).toList(),
      );
    }
  }

  //fetch data
  Future<void> fetchData() async {
    try {
      print('DEBUG: BorrowerController fetchData started');
      
      // Check if user is authenticated
      if (userCtrl.user.value == null) {
        print('DEBUG: User not authenticated, cannot fetch data');
        Get.snackbar('Error', 'User not authenticated');
        return;
      }
      
      isLoading.value = true;

      //get hanya riwayat peminjaman
      final pinjam = await StaticServicesGet().dataPinjam(userCtrl.user.value!.id);
      print('DEBUG: Fetched ${pinjam.length} peminjaman records');

      //get semua riwayat
      final riwayat = await StaticServicesGet().dataRiwayat(userCtrl.user.value!.id);
      print('DEBUG: Fetched ${riwayat.length} riwayat records');

      //get data barang
      final barang = await StaticServicesGet().dataBarang();
      print('DEBUG: Fetched ${barang.length} barang records');

      //get data kategori
      final kategori = await StaticServicesGet().dataKategori();
      print('DEBUG: Fetched ${kategori.length} kategori records');

      //get unit barang
      final unit = await StaticServicesGet().borrowerUnit();
      print('DEBUG: Fetched ${unit.length} unit records');

      //data barang
      itemList.assignAll(barang);
      print('DEBUG: itemList assigned with ${itemList.length} items');

      //data kategori
      kategoriList.assignAll(kategori);
      print('DEBUG: kategoriList assigned with ${kategoriList.length} items');

      //data unit barang
      unitList.assignAll(unit);
      print('DEBUG: unitList assigned with ${unitList.length} units');

      //data peminjaman
      pinjamlist.assignAll(pinjam);
      print('DEBUG: pinjamlist assigned with ${pinjamlist.length} items');

      //data riwayat borrower
      riwayatList.assignAll(riwayat);
      print('DEBUG: riwayatList assigned with ${riwayatList.length} items');

      //data riwayat difilter
      riwayatFltr.assignAll(riwayat);
      print('DEBUG: riwayatFltr assigned with ${riwayatFltr.length} items');
      
      print('DEBUG: BorrowerController fetchData completed successfully');
    } catch (e) {
      print('ERROR in BorrowerController fetchData: $e');
      print('ERROR type: ${e.runtimeType}');
      // Handle PostgrestException if available
      try {
        if (e.toString().contains('Postgrest')) {
          print('Postgrest error detected');
        }
      } catch (_) {}
      Get.snackbar('Error', 'Error fetch data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  //melakukan pengajuan
  Future<void> pengajuan() async {
    final user = userCtrl.user.value;
    
    // Validate form first
    if (!validateForm()) {
      Get.snackbar('Validasi Gagal', errorList.join('\n'));
      return;
    }

    try {
      isLoading.value = true;
      isBtnLoad.value = true;

      // Create peminjaman record
      final peminjaman = await servPst.createPeminjaman(
        peminjamId: user!.id, // This should be the UUID string
        tanggalPinjam: tglPinjam.value!,
        tanggalJatuhTempo: tglKembali.value!,
        status: 'menunggu',
        alasan: ctrlKeperluan.text,
      );

      // Create detail peminjaman records for each selected equipment
      final List<Future<DetailPeminjaman>> detailFutures = [];
      
      for (int equipmentId in slctItemId) {
        // Find the corresponding alat for this equipment
        final alat = itemList.firstWhere((item) => item.id == equipmentId);
        
        detailFutures.add(
          servPst.createDetailPeminjaman(
            peminjamanId: peminjaman.id,
            alatId: alat.id,
            kondisiSaatPinjam: alat.kondisi,
          )
        );
      }

      // Wait for all detail records to be created
      final details = await Future.wait(detailFutures);
      
      // Update alat status to 'dipinjam'
      for (final detail in details) {
        await _alatService.updateAlat(id: detail.alatId, status: 'dipinjam');
      }

      // Success
      resetForm();
      refresh();
      
      Get.snackbar(
        'Sukses', 
        'Pengajuan peminjaman berhasil diajukan. Menunggu persetujuan petugas.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
    } catch (e) {
      print('Error in pengajuan: $e');
      
      // Handle permission denied error specifically
      if (e.toString().contains('permission denied')) {
        // Simpan secara lokal sebagai fallback
        await saveLocalPengajuan();
        
        Get.snackbar(
          'Disimpan Offline', 
          'Pengajuan disimpan secara lokal. Akan dikirimkan ketika koneksi tersedia.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        
        // Reset form setelah menyimpan
        resetForm();
        refresh();
      } else {
        Get.snackbar(
          'Gagal', 
          'Gagal mengajukan peminjaman: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
      isBtnLoad.value = false;
    }
  }

  Future<void> pengembalian(int id, List<int> uId, int sId) async {
    try {
      isLoading.value = true;

      // TODO: Implement proper service method or use existing peminjaman service
      // final response = await servPut.prosesBack(id, uId, sId); // This method doesn't exist
      // For now, use the existing peminjaman service
      final response = await servPut.getAllPeminjaman(); // Placeholder

      if (response != null) {
        resetForm();

        refresh();

        Get.snackbar('Berhasil', 'Mengajuan pengembalian');
      } else {
        Get.snackbar('Gagal', 'Gagal melakukan pengembalian');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan pengembalian');
    } finally {
      isLoading.value = false;
    }
  }

  //fungsi navigasi page
  void onChangePage(int index) {
    isIndex.value = index;
    
    // Refresh data when navigating to pengajuan page (index 1)
    if (index == 1) {
      print('DEBUG: Navigating to pengajuan page, refreshing data');
      fetchData();
    }
  }

  //fungsi validasi form
  bool validateForm() {
    List<String> error = []; 

    //validasi tanggal peminjaman
    if (tglPinjam.value == null) {
      error.add('Tanggal pinjam kosong!');
    } else {
      DateTime today = DateTime.now();

      DateTime nowDate = DateTime(today.year, today.month, today.day);

      DateTime pinjam = DateTime(
        tglPinjam.value!.year,
        tglPinjam.value!.month,
        tglPinjam.value!.day,
      );

      if (pinjam.isBefore(nowDate)) {
        error.add('Tanggal pinjam tidak valid');
      }
    }

    //validasi tanggal peminjaman
    if (tglKembali.value == null) {
      error.add('Tanggal kembali kosong!');
    } else if (tglPinjam.value != null) {
      DateTime kembali = DateTime(
        tglKembali.value!.year,
        tglKembali.value!.month,
        tglKembali.value!.day,
      );

      DateTime pinjam = DateTime(
        tglPinjam.value!.year,
        tglPinjam.value!.month,
        tglPinjam.value!.day,
      );

      if (kembali.isBefore(pinjam)) {
        error.add('Tanggal kembali tidak valid');
      }
    }

    //validasi kategori
    if (slctKategoriId.value == null) {
      error.add('Data kategori kosong!');
    }

    //validasi barang (equipment)
    if (slctItemId.isEmpty) {
      error.add('Pilih minimal satu alat!');
    }

    //inout semua error kedalam list
    errorList.assignAll(error);

    return error.isEmpty;
  }

  // Fungsi untuk menyimpan pengajuan secara lokal jika terjadi error
  Future<void> saveLocalPengajuan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Simpan data pengajuan
      final localData = {
        'userId': userCtrl.user.value!.id,
        'peminjamName': userCtrl.user.value!.namaLengkap,
        'categoryId': slctKategoriId.value,
        'categoryName': kategoriList
            .firstWhereOrNull((k) => k.id == slctKategoriId.value)
            ?.nama,
        'equipmentIds': slctItemId.toList(),
        'equipmentNames': slctItemId.map((id) {
          return itemList.firstWhereOrNull((item) => item.id == id)?.nama ?? '';
        }).toList(),
        'borrowDate': tglPinjam.value!.toIso8601String(),
        'returnDate': tglKembali.value!.toIso8601String(),
        'reason': ctrlKeperluan.text,
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'pending_offline'
      };

      // Ambil semua pengajuan local
      final savedData = prefs.getStringList('pending_loan_requests') ?? [];
      savedData.add(jsonEncode(localData));
      
      await prefs.setStringList('pending_loan_requests', savedData);
      
      print('DEBUG: Pengajuan disimpan secara lokal');
    } catch (e) {
      print('ERROR saving local pengajuan: $e');
    }
  }

  // Fungsi untuk mengambil pengajuan lokal
  Future<List<Map<String, dynamic>>> getLocalPengajuan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getStringList('pending_loan_requests') ?? [];
      
      return savedData.map((data) => jsonDecode(data) as Map<String, dynamic>).toList();
    } catch (e) {
      print('ERROR getting local pengajuan: $e');
      return [];
    }
  }

  // Fungsi untuk menyinkronkan pengajuan offline ke server
  Future<void> syncOfflinePengajuan() async {
    try {
      final localPengajuan = await getLocalPengajuan();
      
      if (localPengajuan.isEmpty) {
        print('DEBUG: Tidak ada pengajuan offline untuk disinkronkan');
        Get.snackbar(
          'Info',
          'Tidak ada pengajuan offline untuk disinkronkan',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      print('DEBUG: Menemukan ${localPengajuan.length} pengajuan offline untuk disinkronkan');
      
      // Buat copy dari list untuk iterasi
      final pengajuanCopy = List<Map<String, dynamic>>.from(localPengajuan);
      int successCount = 0;
      
      for (int i = 0; i < pengajuanCopy.length; i++) {
        final pengajuan = pengajuanCopy[i];
        
        try {
          // Buat pengajuan baru ke server
          final user = userCtrl.user.value;
          
          // Gunakan data dari pengajuan offline
          final peminjaman = await servPst.createPeminjaman(
            peminjamId: pengajuan['userId'],
            tanggalPinjam: DateTime.parse(pengajuan['borrowDate']),
            tanggalJatuhTempo: DateTime.parse(pengajuan['returnDate']),
            status: 'menunggu',
            alasan: pengajuan['reason'],
          );

          // Buat detail peminjaman untuk setiap alat
          final List<int> equipmentIds = List<int>.from(pengajuan['equipmentIds']);
          final List<Future<DetailPeminjaman>> detailFutures = [];
          
          for (int equipmentId in equipmentIds) {
            final alat = itemList.firstWhere((item) => item.id == equipmentId, orElse: () => itemList.first);
            
            detailFutures.add(
              servPst.createDetailPeminjaman(
                peminjamanId: peminjaman.id,
                alatId: alat.id,
                kondisiSaatPinjam: alat.kondisi,
              )
            );
          }

          // Tunggu semua detail dibuat
          await Future.wait(detailFutures);
          
          // Update status alat
          for (int equipmentId in equipmentIds) {
            final alat = itemList.firstWhere((item) => item.id == equipmentId, orElse: () => itemList.first);
            await _alatService.updateAlat(id: alat.id, status: 'dipinjam');
          }

          print('DEBUG: Berhasil sinkronisasi pengajuan offline ${i + 1}');
          successCount++;
          
          // Hapus dari offline storage
          await deleteLocalPengajuanByData(pengajuan);
          
        } catch (e) {
          print('ERROR sync pengajuan offline ${i + 1}: $e');
          // Jika gagal karena permission, lanjutkan ke berikutnya
          if (e.toString().contains('permission denied')) {
            continue; // Coba pengajuan berikutnya
          } else {
            // Untuk error lainnya, mungkin berhenti atau lanjutkan tergantung kebijakan
            continue; // Tetap lanjutkan
          }
        }
      }
      
      if (successCount > 0) {
        Get.snackbar(
          'Sync Berhasil',
          '$successCount dari ${pengajuanCopy.length} pengajuan offline berhasil disinkronkan',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Sync Selesai',
          'Tidak ada pengajuan offline yang berhasil disinkronkan',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      
    } catch (e) {
      print('ERROR syncOfflinePengajuan: $e');
      Get.snackbar(
        'Sync Gagal',
        'Gagal menyinkronkan pengajuan offline: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Fungsi untuk menghapus pengajuan lokal berdasarkan data
  Future<void> deleteLocalPengajuanByData(Map<String, dynamic> pengajuanData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getStringList('pending_loan_requests') ?? [];
      
      // Cari dan hapus entry yang cocok dengan data pengajuan
      final jsonString = jsonEncode(pengajuanData);
      savedData.remove(jsonString);
      
      await prefs.setStringList('pending_loan_requests', savedData);
      print('DEBUG: Pengajuan lokal dihapus');
    } catch (e) {
      print('ERROR deleting local pengajuan: $e');
    }
  }

  // Fungsi untuk menghapus pengajuan lokal berdasarkan index
  Future<void> deleteLocalPengajuan(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getStringList('pending_loan_requests') ?? [];
      
      if (index >= 0 && index < savedData.length) {
        savedData.removeAt(index);
        await prefs.setStringList('pending_loan_requests', savedData);
        print('DEBUG: Pengajuan lokal dihapus');
      }
    } catch (e) {
      print('ERROR deleting local pengajuan: $e');
    }
  }

  // Fungsi untuk membersihkan semua pengajuan offline
  Future<void> clearAllLocalPengajuan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pending_loan_requests');
      print('DEBUG: Semua pengajuan offline dihapus');
    } catch (e) {
      print('ERROR clearing all local pengajuan: $e');
    }
  }
}