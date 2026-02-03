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

    Future<void> ajukanDenda(int detailId) async {
    String? jenisDenda = await Get.defaultDialog<String>(
      title: 'Pilih Jenis Denda',
      content: Column(
        children: [
          ElevatedButton(
              onPressed: () => Get.back(result: 'terlambat'),
              child: const Text('Terlambat')),
          ElevatedButton(
              onPressed: () => Get.back(result: 'rusak'),
              child: const Text('Rusak')),
          ElevatedButton(
              onPressed: () => Get.back(result: 'hilang'),
              child: const Text('Hilang')),
        ],
      ),
      barrierDismissible: false,
    );

    if (jenisDenda != null) {
      final aturanDendaId = await _peminjamanService.getAturanDendaId(jenisDenda);

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


  /// Update status peminjaman (Setujui / Tolak)
  Future<void> updtData(int id, int statusId) async {
  try {
    bttnLoad.value = true;

    String status;
    String pesanSnackbar;

    if (statusId == 2) {
      status = 'dikembalikan';
      pesanSnackbar = 'Pengembalian disetujui';
    } else if (statusId == 3) {
      status = 'ditolak';
      pesanSnackbar = 'Pengembalian ditolak';
    } else {
      status = 'menunggu';
      pesanSnackbar = 'Status tidak dikenal';
    }

    // Update peminjaman
    final result = await _peminjamanService.updatePeminjaman(
      id: id,
      status: status,
      disetujuiOleh: userData?.id,
      tanggalKembali: DateTime.now(),
    );

    if (result) {
      // Ambil detail peminjaman terkait
      final detailList = await _peminjamanService.getDetailByPeminjaman(id);

      // Cek apakah ada keterlambatan atau kerusakan/hilang
      for (var detail in detailList) {
        if (detail.hariTerlambat! > 0 || detail.kondisiSaatKembali != detail.kondisiSaatPinjam) {
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
// Dialog pemberian denda saat setujui/tolak pengembalian
Future<void> showDendaDialog({
  required int peminjamanId,
  required bool isApprove, // true = hanya beri denda, false = setujui/tolak pengembalian
  required Peminjaman model,
}) async {
  bttnLoad.value = true;
  
  // Ambil detail peminjaman & aturan denda
  final details = await _peminjamanService.getDetailByPeminjaman(peminjamanId);
  final aturanDenda = await Supabase.instance.client
      .from('aturan_denda')
      .select('id, jenis, jumlah, keterangan');
  
  bttnLoad.value = false;
  if (details.isEmpty) {
    Get.snackbar('Error', 'Tidak ada detail barang untuk dikenakan denda');
    return;
  }

  // State untuk tracking pilihan denda per item
  final selectedDenda = <int, int?>{}; // key: detail_id, value: aturan_denda_id
  final catatanCtrl = TextEditingController();
  final totalDenda = 0.0.obs;

  // Helper: hitung total denda berdasarkan pilihan
  void hitungTotal() {
    num total = 0;
    for (final entry in selectedDenda.entries) {
      if (entry.value != null) {
        final aturan = (aturanDenda as List)
            .firstWhere((a) => a['id'] == entry.value, orElse: () => null);
        if (aturan != null) total += aturan['jumlah'] as num;
      }
    }
    totalDenda.value = total.toDouble();
  }

  await Get.defaultDialog(
    title: isApprove ? '💰 Terapkan Denda' : (model.status == 'menunggu_pengembalian' ? '✅ Setujui Pengembalian' : '❌ Tolak Pengembalian'),
    content: SizedBox(
      width: Get.width * 0.9, // Responsive width
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview total denda
            Obx(() => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: totalDenda.value > 0 
                    ? Colors.red.shade50 
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    totalDenda.value > 0 ? Icons.attach_money : Icons.check_circle,
                    color: totalDenda.value > 0 ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      totalDenda.value > 0
                          ? 'Total Denda: Rp ${totalDenda.value.toStringAsFixed(0)}'
                          : 'Tidak ada denda',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: totalDenda.value > 0 ? Colors.red.shade800 : Colors.green.shade800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 15),

            // Daftar barang dengan pilihan denda
            const Text(
              'Barang yang Dikembalikan:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            ...details.map((detail) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ${detail.alat?.nama ?? "Barang"}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    // Dropdown pilihan denda
                    Obx(() {
                      final selectedId = selectedDenda[detail.id];
                      return DropdownButtonFormField<int?> (
                        value: selectedId,
                        items: [
                          const DropdownMenuItem<int?> (
                            value: null,
                            child: Text('Tidak ada denda'),
                          ),
                          ...List<DropdownMenuItem<int?>>.from(
                            (aturanDenda as List).map((a) => DropdownMenuItem<int?> (
                              value: a['id'] as int,
                              child: Row(
                                children: [
                                  Icon(
                                    a['jenis'] == 'terlambat' ? Icons.timer : 
                                    a['jenis'] == 'rusak' ? Icons.construction : Icons.delete,
                                    size: 16,
                                    color: a['jenis'] == 'terlambat' ? Colors.orange :
                                           a['jenis'] == 'rusak' ? Colors.red : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${a['jenis'].toString().toUpperCase()} - Rp ${a['jumlah'].toStringAsFixed(0)}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (a['keterangan'] != null) ...[
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '(${a['keterangan']})', 
                                        style: TextStyle(color: Colors.grey, fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )),
                          ),
                        ],
                        onChanged: (value) {
                          selectedDenda[detail.id] = value;
                          hitungTotal();
                        },
                        decoration: InputDecoration(
                          labelText: 'Pilih denda untuk ${detail.alat?.nama ?? "barang"}',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                          isDense: true,
                        ),
                        isExpanded: true,
                      );
                    }),
                  ],
                ),
              ),
            )),

            // Field catatan
            const SizedBox(height: 15),
            TextField(
              controller: catatanCtrl,
              decoration: InputDecoration(
                labelText: 'Catatan (opsional)',
                hintText: 'Contoh: Layar retak pada pojok kiri, baterai lemah...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Tombol aksi
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 400) {
                  // Mobile layout - vertical buttons
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            Get.back(); // Tutup dialog
                            bttnLoad.value = true;

                            try {
                              // 1. Update status peminjaman
                              final now = DateTime.now();
                              String status = model.status; // Default to current status
                              if (!isApprove) { // Only update status if approving/rejecting, not when just applying fine
                                status = model.status == 'menunggu_pengembalian' ? 'dikembalikan' : 'ditolak';
                              }
                              
                              // Hitung hari terlambat (jika ada)
                              int hariTerlambat = 0;
                              if (model.tanggalJatuhTempo.isBefore(now)) {
                                hariTerlambat = now.difference(model.tanggalJatuhTempo).inDays;
                              }

                              final updateSuccess = await _peminjamanService.updatePeminjaman(
                                id: peminjamanId,
                                status: status,
                                disetujuiOleh: userData?.id,
                                tanggalKembali: (!isApprove && model.status == 'menunggu_pengembalian') ? now : null,
                                hariTerlambat: hariTerlambat,
                                alasan: (!isApprove && model.status != 'menunggu_pengembalian' && catatanCtrl.text.isNotEmpty) 
                                    ? 'Pengembalian ditolak: ${catatanCtrl.text}' 
                                    : catatanCtrl.text.isNotEmpty 
                                        ? catatanCtrl.text 
                                        : null,
                              );

                              if (!updateSuccess) throw Exception('Gagal update status peminjaman');

                              // 2. Buat entri denda untuk setiap barang yang dipilih
                              int dendaCount = 0;
                              for (final entry in selectedDenda.entries) {
                                final detailId = entry.key;
                                final aturanId = entry.value;
                                
                                if (aturanId != null) {
                                  final aturan = (aturanDenda as List)
                                      .firstWhere((a) => a['id'] == aturanId);
                                  
                                  final success = await _peminjamanService.createDenda(
                                    detailPeminjamanId: detailId,
                                    aturanDendaId: aturanId,
                                    jumlah: aturan['jumlah'],
                                    diputuskanOleh: userData?.id,
                                    catatan: catatanCtrl.text.isNotEmpty 
                                        ? 'Denda ${aturan['jenis']}: ${catatanCtrl.text}' 
                                        : 'Denda ${aturan['jenis']}',
                                  );
                                  
                                  if (success) dendaCount++;
                                }
                              }

                              // 3. Notifikasi hasil
                              final statusMsg = isApprove 
                                  ? 'Denda diterapkan' 
                                  : (model.status == 'menunggu_pengembalian' ? 'Pengembalian disetujui' : 'Pengembalian ditolak');
                              final dendaMsg = dendaCount > 0 
                                  ? '\nDenda diterapkan: $dendaCount item (Rp ${totalDenda.value.toStringAsFixed(0)})' 
                                  : '';
                              
                              Get.snackbar(
                                isApprove ? '💰 Berhasil' : '✅ Berhasil',
                                '$statusMsg$dendaMsg',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: isApprove ? Colors.orange.shade50 : Colors.green.shade50,
                                colorText: isApprove ? Colors.orange.shade900 : Colors.green.shade900,
                                duration: const Duration(seconds: 4),
                              );
                              
                              await fetchData();
                            } catch (e) {
                              Get.snackbar(
                                '❌ Error',
                                'Gagal memproses: ${e.toString()}',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red.shade50,
                                colorText: Colors.red.shade900,
                              );
                            } finally {
                              bttnLoad.value = false;
                              catatanCtrl.dispose();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isApprove ? Colors.orange : (model.status == 'menunggu_pengembalian' ? Colors.green : Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            isApprove ? 'Terapkan Denda' : (model.status == 'menunggu_pengembalian' ? 'Setujui & Beri Denda' : 'Tolak & Beri Denda'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: Get.back,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Desktop layout - horizontal buttons
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: Get.back,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Get.back(); // Tutup dialog
                            bttnLoad.value = true;

                            try {
                              // 1. Update status peminjaman
                              final now = DateTime.now();
                              String status = model.status; // Default to current status
                              if (!isApprove) { // Only update status if approving/rejecting, not when just applying fine
                                status = model.status == 'menunggu_pengembalian' ? 'dikembalikan' : 'ditolak';
                              }
                              
                              // Hitung hari terlambat (jika ada)
                              int hariTerlambat = 0;
                              if (model.tanggalJatuhTempo.isBefore(now)) {
                                hariTerlambat = now.difference(model.tanggalJatuhTempo).inDays;
                              }

                              final updateSuccess = await _peminjamanService.updatePeminjaman(
                                id: peminjamanId,
                                status: status,
                                disetujuiOleh: userData?.id,
                                tanggalKembali: (!isApprove && model.status == 'menunggu_pengembalian') ? now : null,
                                hariTerlambat: hariTerlambat,
                                alasan: (!isApprove && model.status != 'menunggu_pengembalian' && catatanCtrl.text.isNotEmpty) 
                                    ? 'Pengembalian ditolak: ${catatanCtrl.text}' 
                                    : catatanCtrl.text.isNotEmpty 
                                        ? catatanCtrl.text 
                                        : null,
                              );

                              if (!updateSuccess) throw Exception('Gagal update status peminjaman');

                              // 2. Buat entri denda untuk setiap barang yang dipilih
                              int dendaCount = 0;
                              for (final entry in selectedDenda.entries) {
                                final detailId = entry.key;
                                final aturanId = entry.value;
                                
                                if (aturanId != null) {
                                  final aturan = (aturanDenda as List)
                                      .firstWhere((a) => a['id'] == aturanId);
                                  
                                  final success = await _peminjamanService.createDenda(
                                    detailPeminjamanId: detailId,
                                    aturanDendaId: aturanId,
                                    jumlah: aturan['jumlah'],
                                    diputuskanOleh: userData?.id,
                                    catatan: catatanCtrl.text.isNotEmpty 
                                        ? 'Denda ${aturan['jenis']}: ${catatanCtrl.text}' 
                                        : 'Denda ${aturan['jenis']}',
                                  );
                                  
                                  if (success) dendaCount++;
                                }
                              }

                              // 3. Notifikasi hasil
                              final statusMsg = isApprove 
                                  ? 'Denda diterapkan' 
                                  : (model.status == 'menunggu_pengembalian' ? 'Pengembalian disetujui' : 'Pengembalian ditolak');
                              final dendaMsg = dendaCount > 0 
                                  ? '\nDenda diterapkan: $dendaCount item (Rp ${totalDenda.value.toStringAsFixed(0)})' 
                                  : '';
                              
                              Get.snackbar(
                                isApprove ? '💰 Berhasil' : '✅ Berhasil',
                                '$statusMsg$dendaMsg',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: isApprove ? Colors.orange.shade50 : Colors.green.shade50,
                                colorText: isApprove ? Colors.orange.shade900 : Colors.green.shade900,
                                duration: const Duration(seconds: 4),
                              );
                              
                              await fetchData();
                            } catch (e) {
                              Get.snackbar(
                                '❌ Error',
                                'Gagal memproses: ${e.toString()}',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red.shade50,
                                colorText: Colors.red.shade900,
                              );
                            } finally {
                              bttnLoad.value = false;
                              catatanCtrl.dispose();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isApprove ? Colors.orange : (model.status == 'menunggu_pengembalian' ? Colors.green : Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            isApprove ? 'Terapkan Denda' : (model.status == 'menunggu_pengembalian' ? 'Setujui & Beri Denda' : 'Tolak & Beri Denda'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
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