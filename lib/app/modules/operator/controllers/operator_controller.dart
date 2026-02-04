import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/data/models/Peminjaman.dart';
import 'package:inven/app/data/models/ProfilPengguna.dart';
import 'package:inven/app/data/services/peminjaman_service.dart';
import 'package:inven/app/global/controllers/global_user_controller.dart';
import 'package:inven/app/modules/admin/controllers/aturan_denda_controller.dart';
import 'package:inven/app/modules/login/controllers/login_controller.dart';
import 'package:inven/app/modules/login/views/login_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OperatorController extends GetxController {
  late final GlobalUserController userCtrl;
  final PeminjamanService _peminjamanService = PeminjamanService();
    final AturanDendaController controller = Get.put(AturanDendaController());
    final PeminjamanService peminjamanService = PeminjamanService();
    final hariTerlambatController = TextEditingController();
final isTerlambat = false.obs;
void setJenisDenda(String value) {
  final aturanC = Get.find<AturanDendaController>();
  aturanC.jenisController.value = value;
  isTerlambat.value = value == 'terlambat';
}



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
  hariTerlambatController.dispose();
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
    final select = selectOpsi.value;
    riwayatFilter.assignAll(
      select == 0
          ? riwayatAll
          : riwayatAll
                .where((r) => r.status == getStatusString(select))
                .toList(),
    );
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
        .where((e) => e.value)
        .map(
          (e) => {
            'id_unit': e.key,
            'status_baru': 1,
            'catatan': ctrlNote.text.isNotEmpty ? ctrlNote.text : null,
          },
        )
        .toList();
  }

  Future<void> ajukanDenda(int detailId) async {
    final jenisDenda = await Get.defaultDialog<String>(
      title: 'Pilih Jenis Denda',
      content: Column(
        children: [
          ElevatedButton(
            onPressed: () => Get.back(result: 'terlambat'),
            child: const Text('Terlambat'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: 'rusak'),
            child: const Text('Rusak'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: 'hilang'),
            child: const Text('Hilang'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (jenisDenda != null) {
      final aturanDendaId = await _peminjamanService.getAturanDendaId(
        jenisDenda,
      );

      if (aturanDendaId == null) {
        Get.snackbar('Error', 'Aturan denda tidak ditemukan');
        return;
      }

      final success = await _peminjamanService.createDenda(
        detailPeminjamanId: detailId,
        aturanDendaId: aturanDendaId,
        jumlah: await _peminjamanService.getJumlahDenda(aturanDendaId),
        diputuskanOleh: userData?.id,
      );

      if (success) {
        Get.snackbar('Sukses', 'Denda berhasil ditambahkan');
        await fetchData();
      } else {
        Get.snackbar('Error', 'Gagal menambahkan denda');
      }
    }
  }

  Future<void> updtData(int id, int statusId) async {
    bttnLoad.value = true;
    try {
      String status;
      String pesanSnackbar;

      if (statusId == 2) {
        status = 'setujui_pinjam';
        pesanSnackbar = 'Peminjaman disetujui';
      } else if (statusId == 3) {
        status = 'tolak_pijam';
        pesanSnackbar = 'Peminjaman ditolak';
      } else if (statusId == 4) {
        status = 'tunggu_pengembalian';
        pesanSnackbar = 'Tunggu Pengembalian';
      } else if (statusId == 5) {
        status = 'setujui_pengembalian';
        pesanSnackbar = 'Setujui Pengembalian';
      } else if (statusId == 6) {
        status = 'tolak_pengembalian';
        pesanSnackbar = 'Tolak Pengembalian';
      } else if (statusId == 7) {
        status = 'denda';
        pesanSnackbar = 'Anda Dikenakan denda';
      } else {
        status = 'tolak';
        pesanSnackbar = 'Status tidak dikenal';
      }

      final result = await _peminjamanService.updatePeminjaman(
        id: id,
        status: status,
        disetujuiOleh: userData?.id,
        tanggalKembali: DateTime.now(),
      );

      if (result) {
        final detailList = await _peminjamanService.getDetailByPeminjaman(id);
        for (var detail in detailList) {
          if ((detail.hariTerlambat ?? 0) > 0 ||
              detail.kondisiSaatKembali != detail.kondisiSaatPinjam) {
            await ajukanDenda(detail.id);
          }
        }

        Get.snackbar('Sukses', pesanSnackbar);
        await fetchData();
      } else {
        Get.snackbar('Gagal', 'Terjadi kegagalan proses');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      bttnLoad.value = false;
    }
  }

Future<void> ajukanPengembalian(int id) async {
  bttnLoad.value = true;

  try {
    final now = DateTime.now();

    final result = await _peminjamanService.updatePeminjaman(
      id: id,
      status: 'tunggu_pengembalian',
      tanggalKembali: now,
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
    isLoading.value = true;
    try {
      final dataAll = await _peminjamanService.getAllPeminjaman();

      pengajuan.assignAll(
        dataAll
            .where((p) => p.status.toLowerCase() == 'tunggu_pinjam')
            .toList(),
      );
      kembalian.assignAll(
        dataAll
            .where((p) => p.status.toLowerCase() == 'tunggu_pengembalian')
            .toList(),
      );
      riwayatAll.assignAll(dataAll);
      riwayatFilter.assignAll(dataAll);

      print("DEBUG: Pengajuan Baru = ${pengajuan.length}");
      print("DEBUG: Pengembalian = ${kembalian.length}");
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterD() {
    _debounce?.cancel();
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
Future<void> showDendaDialog({
  required int peminjamanId,
  required bool isApprove,
  required Peminjaman model,
}) async {
  final aturanC = Get.find<AturanDendaController>();
  final peminjamanService = PeminjamanService();

  await Get.dialog(
    AlertDialog(
      title: const Text('Beri Denda'),
      content: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: aturanC.jenisController.value.isEmpty
                    ? null
                    : aturanC.jenisController.value,
                items: aturanC.jenisOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setJenisDenda(v ?? ''),
                decoration:
                    const InputDecoration(labelText: 'Jenis Denda'),
              ),
              const SizedBox(height: 12),

              if (isTerlambat.value)
                TextField(
                  controller: hariTerlambatController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Hari Terlambat',
                    border: OutlineInputBorder(),
                  ),
                ),
            ],
          )),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            final jenis = aturanC.jenisController.value;

            if (jenis.isEmpty) {
              Get.snackbar('Error', 'Pilih jenis denda dulu');
              return;
            }

            int hariTerlambat = 0;
            int harga = 0;

            if (jenis == 'terlambat') {
              hariTerlambat =
                  int.tryParse(hariTerlambatController.text) ?? 0;

              if (hariTerlambat <= 0) {
                Get.snackbar('Error', 'Masukkan jumlah hari terlambat');
                return;
              }

              // 🔥 HITUNG OTOMATIS DENDA
              harga = hariTerlambat * 5000;
            }

            try {
              final aturan =
                  aturanC.listAturan.firstWhere((e) => e.jenis == jenis);

              /// 🔥 DEBUG DATA
              print("========== KIRIM DENDA ==========");
              print("peminjamanId   : $peminjamanId");
              print("jenis denda    : ${aturan.jenis}");
              print("aturanDendaId  : ${aturan.id}");
              print("hariTerlambat  : $hariTerlambat");
              print("statusApprove? : $isApprove");
              print("TOTAL DENDA    : $harga");
              print("=================================");

              await peminjamanService.beriDenda(
                peminjamanId,
                aturan.id,
                hariTerlambat,
                harga,
              );

              aturanC.resetForm();
              hariTerlambatController.clear();
              isTerlambat.value = false;

              Get.back();

              Get.snackbar(
                'Berhasil',
                'Denda ${aturan.jenis} ditambahkan\nTotal: Rp $harga',
              );
            } catch (e) {
              print("ERROR SIMPAN DENDA: $e");
              Get.snackbar('Error', 'Gagal menyimpan denda');
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
}




}
