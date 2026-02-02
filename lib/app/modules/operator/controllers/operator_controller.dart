import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/data/models/Peminjaman.dart';
import 'package:inven/app/data/models/ProfilPengguna.dart';
import 'package:inven/app/data/services/peminjaman_service.dart';
import 'package:inven/app/global/controllers/global_user_controller.dart';
import 'package:inven/app/modules/login/controllers/login_controller.dart';
import 'package:inven/app/modules/login/views/login_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/AppUser.dart';
import '../../../data/services/database_service_provider.dart';

class OperatorController extends GetxController {
  late final GlobalUserController userCtrl;
  final PeminjamanService _peminjamanService = PeminjamanService();

  ProfilPengguna? get userData => userCtrl.user.value;

  @override
  void onClose() {
    ctrlNote.dispose();
    ctrlFill.dispose();
    focusFil.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    // Safely get GlobalUserController
    try {
      userCtrl = Get.find<GlobalUserController>();
    } catch (e) {
      // If not found, create a new one
      userCtrl = Get.put(GlobalUserController());
    }
                
    super.onInit();
    fetchUserProfile();
    fetchData();
  }
  Future<void> fetchUserProfile() async {
    try {
      final userId = userCtrl.user.value?.id ?? DatabaseServiceProvider.currentUserId;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('vw_user_with_email')
          .select()
          .eq('id', userId)
          .single();

      // Update user di GlobalUserController
      userCtrl.user.value = ProfilPengguna.fromJson(response);
      print("DEBUG: User Profile = ${userCtrl.user.value?.toJson()}");
    } catch (e) {
      print("ERROR FETCH USER PROFILE: $e");
      Get.snackbar(
        "Error",
        "Gagal memuat data profil",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
    }
  }

  final expandP = ''.obs; //expand proses
  final expandR = ''.obs; //expand riwayat
  final expandB = ''.obs; //expand pengembalian (back)

  var bttnLoad = false.obs; //loading indikator
  var isLoading = false.obs; //loading value

  var selectUnit = <int, bool>{}.obs;
  final ctrlNote = TextEditingController();
  final ctrlFill = TextEditingController();
  final focusFil = FocusNode();

  final pengajuan = <Peminjaman>[].obs;
  final kembalian = <Peminjaman>[].obs;
  final riwayatAll = <Peminjaman>[].obs;
  var riwayatFilter = <Peminjaman>[].obs;

  Timer? _debounce;

  final Map<int, String> opsiFilter = {
    0: '|||',
    1: 'Menunggu',
    2: 'Disetujui',
    3: 'Ditolak',
    4: 'Dikembalikan',
  };
  var selectOpsi = 0.obs;



  void filterChips() {
    int select = selectOpsi.value;

    if (select == 0) {
      riwayatFilter.assignAll(riwayatAll);
    } else {
      riwayatFilter.assignAll(
        riwayatAll
            .where((r) => r.status == getStatusString(select))
            .toList(),
      );
    }
  }

  String getStatusString(int statusId) {
    switch (statusId) {
      case 1: return 'menunggu';
      case 2: return 'disetujui';
      case 3: return 'ditolak';
      case 4: return 'dikembalikan';
      default: return 'menunggu';
    }
  }

  void doLogout() {
    Get.offAll(
      () => LoginView(),
      binding: BindingsBuilder(() {
        Get.put(GlobalUserController());
        Get.put(LoginController());
      }),
    );
  }

  void initUnit(List<dynamic> units) {
    selectUnit.clear();
    // Implementation for unit selection
  }
  
  void cetakPdfRiwayat() {
    Get.snackbar('Info', 'Fitur cetak PDF akan segera tersedia');
  }

  List<Map<String, dynamic>> getSelectUnit() {
    return selectUnit.entries
        .where((e) => e.value == true)
        .map(
          (e) => {
            'id_unit': e.key,
            'status_baru': 1,
            'catatan': ctrlNote.text.isNotEmpty ? ctrlNote.text : null,
          },
        )
        .toList();
  }

  Future<void> updtData(int id, int statusId) async {
    try {
      bttnLoad.value = true;

      final note = ctrlNote.text;
      final status = getStatusString(statusId);
      
      final result = await _peminjamanService.updatePeminjaman(
        id: id,
        status: status,
        alasan: note,
        disetujuiOleh: userData?.id,
      );

      if (result) {
        Get.snackbar(
          'Sukses',
          statusId == 2 ? 'Pengajuan disetujui' : 'Pengajuan ditolak',
        );
        await fetchData(); // Refresh data
      } else {
        Get.snackbar('Gagal', 'Terjadi kegagalan proses');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan $e');
    } finally {
      bttnLoad.value = false;
    }
  }

  Future<void> pengembalian(int id) async {
    try {
      isLoading.value = true;
      bttnLoad.value = true;

      final unit = getSelectUnit();
      // Update peminjaman status to 'dikembalikan'
      final result = await _peminjamanService.updatePeminjaman(
        id: id,
        status: 'dikembalikan',
        tanggalKembali: DateTime.now(),
      );

      if (result) {
        Get.back();
        Get.snackbar('Sukses', 'Pengembalian diproses');
        await fetchData(); // Refresh data
      } else {
        Get.snackbar('Gagal', 'Pengembalian gagal');
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'message: $e');
    } finally {
      isLoading.value = false;
      bttnLoad.value = false;
    }
  }

  Future<void> refresh() async {
    isLoading.value = true;

    await Future.delayed(Duration(seconds: 1));

    await fetchData();

    await Future.delayed(Duration(seconds: 1));

    isLoading.value = false;
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;

      final dataPengajuan = await _peminjamanService.getAllPeminjaman();
      final pengembalian = dataPengajuan.where((p) => p.status == 'dikembalikan').toList();
      final riwayatData = dataPengajuan;

      pengajuan.assignAll(dataPengajuan);
      kembalian.assignAll(pengembalian);
      riwayatAll.assignAll(riwayatData);
      print('cek status: ${riwayatAll.map((e) => e.status)}');
      riwayatFilter.assignAll(riwayatData);
    } catch (e) {
      Get.snackbar('Error', 'Error fetch data controller: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterD() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(Duration(milliseconds: 300), () {
      final keyword = ctrlFill.text.toLowerCase();

      if (keyword.isEmpty) {
        pengajuan.assignAll(riwayatAll);
        return;
      }

      final hasil = riwayatAll.where((r) {
        final peminjam = r.peminjam?.namaLengkap.toLowerCase() ?? '';
        final alasan = r.alasan?.toLowerCase() ?? '';
        
        return peminjam.contains(keyword) ||
            alasan.contains(keyword);
      }).toList();

      pengajuan.assignAll(hasil);
    });
  }
}
