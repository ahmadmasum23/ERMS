import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/data/models/AppPengajuan.dart';
import 'package:inven/app/data/models/AppUnitBarang.dart';
import 'package:inven/app/data/models/AppUser.dart';
import 'package:inven/app/data/static_data/static_services_get.dart';
import 'package:inven/app/data/static_data/static_services_update.dart';
import 'package:inven/app/global/controllers/global_user_controller.dart';
import 'package:inven/app/modules/login/controllers/login_controller.dart';
import 'package:inven/app/modules/login/views/login_view.dart';

class OperatorController extends GetxController {
  late final GlobalUserController userCtrl;
  final services = StaticServicesGet();

  AppUser? get userData => userCtrl.user.value;

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
    fetchData();
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

  final pengajuan = <AppPengajuan>[].obs;
  final kembalian = <AppPengajuan>[].obs;
  final riwayatAll = <AppPengajuan>[].obs;
  var riwayatFilter = <AppPengajuan>[].obs;

  Timer? _debounce;

  final Map<int, String> opsiFilter = {
    0: '|||',
    8: 'Proses',
    1: 'Ditolak',
    4: 'Dipinjam',
    2: 'Selesai',
  };
  var selectOpsi = 0.obs;



  void filterChips() {
    int select = selectOpsi.value;

    if (select == 0) {
      riwayatFilter.assignAll(riwayatAll);
    } else if (select == 8) {
      riwayatFilter.assignAll(
        riwayatAll
            .where((r) => r.status?.id == 3 || r.status?.id == 5)
            .toList(),
      );
    } else if (select == 2) {
      riwayatFilter.assignAll(
        riwayatAll
            .where((r) => r.status?.id == 2 || r.status?.id == 6)
            .toList(),
      );
    } else {
      riwayatFilter.assignAll(
        riwayatAll.where((r) => r.status?.id == select).toList(),
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

  void initUnit(List<AppUnitBarang> units) {
    selectUnit.clear();
    for (final u in units) {
      selectUnit[u.id] = false;
    }
  }
  
  void cetakPdfRiwayat() {
  // TODO: Implementasi PDF (gunakan package seperti `pdf` dan `printing`)
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
      final result = await StaticServicesUpdate().prosesAppr(id, statusId, note);

      if (result != null) {
        Get.snackbar(
          'Sukses',
          statusId == 4 ? 'Pengajuan disetujui' : 'Pengajuan ditolak',
        );
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
      final result = await StaticServicesUpdate().prosesRett(id, unit);

      if (result != null) {
        Get.back();
        Get.snackbar('Sukses', 'Pengembalian diproses');
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

      final dataPengajuan = await services.indexApp();
      final pengembalian = await services.returnApp();
      final riwayatData = await services.indexAll();

      pengajuan.assignAll(dataPengajuan);
      kembalian.assignAll(pengembalian);
      riwayatAll.assignAll(riwayatData);
      print('cek status: ${riwayatAll.map((e) => e.status?.id)}');
      riwayatFilter.assignAll(riwayatData);
    } catch (e) {
      Get.snackbar('Error', 'Error fetch data controller');
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
        final pengguna = r.pengguna!.nama.toLowerCase();
        final keperluan = r.hal!.toLowerCase();
        final barang = r.unit
            ?.map((u) => u.barang!.nmBarang.toLowerCase())
            .join(' ');

        return barang!.contains(keyword) ||
            keperluan.contains(keyword) ||
            pengguna.contains(keyword);
      }).toList();

      pengajuan.assignAll(hasil);
    });
  }
}
