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

class OperatorController extends GetxController {
  late final GlobalUserController userCtrl;
  final PeminjamanService _peminjamanService = PeminjamanService();

  ProfilPengguna? get userData => userCtrl.user.value;

  // Expand panel
  final expandP = ''.obs;
  final expandR = ''.obs;
  final expandB = ''.obs;

  // Loading indikator
  var bttnLoad = false.obs;
  var isLoading = false.obs;

  // Unit selection
  var selectUnit = <int, bool>{}.obs;
  final ctrlNote = TextEditingController();
  final ctrlFill = TextEditingController();
  final focusFil = FocusNode();

  // Data peminjaman
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

  @override
  void onInit() {
    super.onInit();

    // Ambil GlobalUserController
    try {
      userCtrl = Get.find<GlobalUserController>();
    } catch (_) {
      userCtrl = Get.put(GlobalUserController());
    }

    fetchUserProfile();
    fetchData();
  }

  @override
  void onClose() {
    ctrlNote.dispose();
    ctrlFill.dispose();
    focusFil.dispose();
    super.onClose();
  }

  Future<void> fetchUserProfile() async {
    try {
      final userId = userCtrl.user.value?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('vw_user_with_email')
          .select()
          .eq('id', userId)
          .single();

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

  String getStatusString(int statusId) {
    switch (statusId) {
      case 1:
        return 'menunggu';
      case 2:
        return 'disetujui';
      case 3:
        return 'ditolak';
      case 4:
        return 'dikembalikan';
      default:
        return 'menunggu';
    }
  }

  void filterChips() {
    int select = selectOpsi.value;

    if (select == 0) {
      riwayatFilter.assignAll(riwayatAll);
    } else {
      riwayatFilter.assignAll(
        riwayatAll.where((r) => r.status == getStatusString(select)).toList(),
      );
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
    // implementasi unit selection jika dibutuhkan
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

  /// Update status peminjaman (Setujui / Tolak)
  Future<void> updtData(int id, int statusId) async {
    try {
      bttnLoad.value = true;

      final note = ctrlNote.text;

      String status;
      String pesanSnackbar;

      if (statusId == 2) {
        status = 'disetujui';
        pesanSnackbar = 'Pengajuan disetujui';
      } else if (statusId == 3) {
        status = 'ditolak';
        pesanSnackbar = 'Pengajuan ditolak';
      } else {
        status = 'menunggu';
        pesanSnackbar = 'Status tidak dikenal';
      }

      final result = await _peminjamanService.updatePeminjaman(
        id: id,
        status: status,
        alasan: note,
        disetujuiOleh: userData?.id,
      );

      if (result) {
        Get.snackbar(
          'Sukses',
          pesanSnackbar,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchData();
      } else {
        Get.snackbar(
          'Gagal',
          'Terjadi kegagalan proses',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      bttnLoad.value = false;
    }
  }
//  fungsi ajukan pengembalian
 Future<void> ajukanPengembalian(int id) async {
  try {
    bttnLoad.value = true;

    final now = DateTime.now(); // waktu sekarang

    final result = await _peminjamanService.updatePeminjaman(
      id: id,
      status: 'menunggu_pengembalian', // status tetap valid di DB
      tanggalKembali: now, // isi kolom tanggal_kembali
    );

    if (result) {
      Get.snackbar('Sukses', 'Pengajuan pengembalian dikirim');
      await fetchData();
    } else {
      Get.snackbar('Gagal', 'Gagal mengajukan pengembalian');
    }
  } catch (e) {
    Get.snackbar('Error', 'Terjadi kesalahan: $e');
  } finally {
    bttnLoad.value = false;
  }
}




  Future<void> refresh() async {
    isLoading.value = true;

    await Future.delayed(const Duration(seconds: 1));

    await fetchData();

    await Future.delayed(const Duration(seconds: 1));

    isLoading.value = false;
  }

 Future<void> fetchData() async {
  try {
    isLoading.value = true;

    final dataPengajuan = await _peminjamanService.getAllPeminjaman();

    // pengembalian = yang diajukan pengembalian oleh peminjam
    final pengembalian = dataPengajuan
        .where((p) => p.status == 'menunggu_pengembalian')
        .toList();

    pengajuan.assignAll(dataPengajuan);
    kembalian.assignAll(pengembalian); // ini untuk panel operator
    riwayatAll.assignAll(dataPengajuan);
    riwayatFilter.assignAll(dataPengajuan);
  } catch (e) {
    Get.snackbar('Error', 'Error fetch data controller: $e');
  } finally {
    isLoading.value = false;
  }
}


  void filterD() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      final keyword = ctrlFill.text.toLowerCase();

      if (keyword.isEmpty) {
        pengajuan.assignAll(riwayatAll);
        return;
      }

      final hasil = riwayatAll.where((r) {
        final peminjam = r.peminjam?.namaLengkap.toLowerCase() ?? '';
        final alasan = r.alasan?.toLowerCase() ?? '';

        return peminjam.contains(keyword) || alasan.contains(keyword);
      }).toList();

      pengajuan.assignAll(hasil);
    });
  }
}
