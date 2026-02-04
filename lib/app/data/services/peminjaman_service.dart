import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import '../models/Peminjaman.dart';
import '../models/DetailPeminjaman.dart';
import '../models/ProfilPengguna.dart';

class PeminjamanService {
  final SupabaseClient _supabase = AuthService().client;

  Future<void> setujuiPengembalian(
  int peminjamanId,
  DateTime tanggalJatuhTempo,
) async {
  final tanggalKembali = DateTime.now();

  final selisihHari =
      tanggalKembali.difference(tanggalJatuhTempo).inDays;

  int hariTerlambat = selisihHari > 0 ? selisihHari : 0;

  Map<String, dynamic> updateData = {
    'tanggal_kembali': tanggalKembali.toIso8601String(),
    'hariTerlambat': hariTerlambat,
    'status': 'setujui_pengembalian',
  };

  // 🔥 LOGIC DENDA OTOMATIS DI SINI
  if (hariTerlambat > 0) {
    final aturan = await _supabase
        .from('aturan_denda')
        .select()
        .eq('jenis', 'terlambat')
        .single();

    updateData['denda_id'] = aturan['id'];
    updateData['status_denda'] = 'kena_denda';
    updateData['status'] = 'denda';
  } else {
    updateData['status_denda'] = 'tidak_ada';
  }

  await _supabase
      .from('peminjaman')
      .update(updateData)
      .eq('id', peminjamanId);
}


  // Ambil semua peminjaman
  Future<List<Peminjaman>> getAllPeminjaman() async {
    try {
      final response = await _supabase
          .from('peminjaman')
          .select('*, peminjam:profil_pengguna!peminjaman_peminjam_id_fkey(*), petugas:profil_pengguna!peminjaman_disetujui_oleh_fkey(*)')
          .order('tanggal_pinjam', ascending: false);

      return (response as List<dynamic>)
          .map((e) => Peminjaman.fromJson(e))
          .toList();
    } catch (e) {
      print("ERROR FETCH ALL PEMINJAMAN: $e");
      rethrow;
    }
  }

  // Ambil peminjaman berdasarkan user
  Future<List<Peminjaman>> getPeminjamanByUser(String userId) async {
    try {
      final response = await _supabase
          .from('peminjaman')
          .select('*, peminjam:profil_pengguna!peminjaman_peminjam_id_fkey(*), petugas:profil_pengguna!peminjaman_disetujui_oleh_fkey(*)')
          .eq('peminjam_id', userId)
          .order('tanggal_pinjam', ascending: false);

      return (response as List<dynamic>)
          .map((e) => Peminjaman.fromJson(e))
          .toList();
    } catch (e) {
      print("ERROR FETCH PEMINJAMAN BY USER: $e");
      rethrow;
    }
  }

  // Ambil detail peminjaman
  Future<List<DetailPeminjaman>> getDetailByPeminjaman(int peminjamanId) async {
    final result = await _supabase
        .from('detail_peminjaman')
        .select('*, alat:alat(*)')
        .eq('peminjaman_id', peminjamanId);

    return (result as List<dynamic>)
        .map((e) => DetailPeminjaman.fromJson(e))
        .toList();
  }

  // Ambil peminjaman by ID
  Future<Peminjaman?> getPeminjamanById(int id) async {
    try {
      final response = await _supabase
          .from('peminjaman')
          .select('*, peminjam:profil_pengguna!peminjaman_peminjam_id_fkey(*), petugas:profil_pengguna!peminjaman_disetujui_oleh_fkey(*)')
          .eq('id', id)
          .limit(1);

      final list = response as List<dynamic>;
      if (list.isEmpty) return null;
      return Peminjaman.fromJson(list.first);
    } catch (e) {
      print("ERROR FETCH PEMINJAMAN BY ID: $e");
      return null;
    }
  }

  // Buat peminjaman baru
  Future<Peminjaman> createPeminjaman({
    required String peminjamId,
    required DateTime tanggalPinjam,
    required DateTime tanggalJatuhTempo,
    required String status, // harus sesuai DB: menunggu/disetujui/dll
    String? alasan,
  }) async {
    try {
      final response = await _supabase
          .from('peminjaman')
          .insert({
            'peminjam_id': peminjamId,
            'tanggal_pinjam': tanggalPinjam.toIso8601String(),
            'tanggal_jatuh_tempo': tanggalJatuhTempo.toIso8601String(),
            'status': status,
            'alasan': alasan,
          })
          .select('*, peminjam:profil_pengguna!peminjaman_peminjam_id_fkey(*), petugas:profil_pengguna!peminjaman_disetujui_oleh_fkey(*)')
          .limit(1);

      final list = response as List<dynamic>;
      if (list.isEmpty) throw Exception('Failed to create peminjaman');
      return Peminjaman.fromJson(list.first);
    } catch (e) {
      print("ERROR CREATE PEMINJAMAN: $e");
      rethrow;
    }
  }
Future<void> beriDenda(int peminjamanId, int aturanDendaId,  int hariTerlambat,int harga) async {
  await _supabase.from('peminjaman').update({
    'denda_id': aturanDendaId,
    'status_denda': 'kena_denda',
        'hariTerlambat': hariTerlambat,
    'status': 'denda',
    'harga':harga
  }).eq('id', peminjamanId);
}


Future<void> updateStatusDenda(int peminjamanId, String status) async {
  await _supabase
      .from('peminjaman')
      .update({'status_denda': status}).eq('id', peminjamanId);
}


  // Update peminjaman
  Future<bool> updatePeminjaman({ 
    required int id,
    String? disetujuiOleh,
    DateTime? tanggalKembali,
    String? status,
    int? hariTerlambat,
    String? alasan,
  }) async {
    try {
      if (id == 0) return false;

      final Map<String, dynamic> updateData = {};
      if (disetujuiOleh != null) updateData['disetujui_oleh'] = disetujuiOleh;
      if (tanggalKembali != null) updateData['tanggal_kembali'] = tanggalKembali.toIso8601String();
      if (status != null) updateData['status'] = status; // langsung pakai value DB
      if (hariTerlambat != null) updateData['hari_terlambat'] = hariTerlambat;
      if (alasan != null) updateData['alasan'] = alasan;

      final response = await _supabase
          .from('peminjaman')
          .update(updateData)
          .eq('id', id)
          .select();

      return (response as List<dynamic>).isNotEmpty;
    } catch (e) {
      print("ERROR UPDATE PEMINJAMAN: $e");
      return false;
    }
  }

  // Delete peminjaman
  Future<bool> deletePeminjaman(int id) async {
    try {
      await _supabase.from('peminjaman').delete().eq('id', id);
      return true;
    } catch (e) {
      print("ERROR DELETE PEMINJAMAN: $e");
      return false;
    }
  }

  // Ambil semua denda dari peminjaman
  Future<List<Map<String, dynamic>>> getDendaByPeminjaman(int peminjamanId) async {
    try {
      final detailIds = await _getDetailIdsByPeminjaman(peminjamanId);
      if (detailIds.isEmpty) return [];

      final result = await _supabase
          .from('denda')
          .select('*, aturan:aturan_denda(*)')
          .filter('detail_peminjaman_id', 'in', detailIds);

      return (result as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      print("ERROR GET DENDA BY PEMINJAMAN: $e");
      return [];
    }
  }

  Future<int?> getAturanDendaId(String jenis) async {
    try {
      final response = await _supabase
          .from('aturan_denda')
          .select('id')
          .eq('jenis', jenis)
          .single();
      return response?['id'];
    } catch (e) {
      print("ERROR GET ATURAN DENDA ID: $e");
      return null;
    }
  }

  Future<num> getJumlahDenda(int aturanDendaId) async {
    try {
      final response = await _supabase
          .from('aturan_denda')
          .select('jumlah')
          .eq('id', aturanDendaId)
          .single();
      return response?['jumlah'] ?? 0;
    } catch (e) {
      print("ERROR GET JUMLAH DENDA: $e");
      return 0;
    }
  }

  Future<bool> createDenda({
    required int detailPeminjamanId,
    required int aturanDendaId,
    required num jumlah,
    required String? diputuskanOleh,
    String? catatan,
  }) async {
    try {
      final response = await _supabase
          .from('denda')
          .insert({
            'detail_peminjaman_id': detailPeminjamanId,
            'aturan_denda_id': aturanDendaId,
            'jumlah': jumlah,
            'diputuskan_oleh': diputuskanOleh,
            'catatan': catatan,
          })
          .select()
          .limit(1);

      final list = response as List<dynamic>;
      return list.isNotEmpty;
    } catch (e) {
      print("ERROR CREATE DENDA: $e");
      return false;
    }
  }

  // Helper ambil semua detail_id dari peminjaman
  Future<List<int>> _getDetailIdsByPeminjaman(int peminjamanId) async {
    final details = await getDetailByPeminjaman(peminjamanId);
    return details.map((d) => d.id).toList();
  }

  // Detail Peminjaman
  Future<DetailPeminjaman> createDetailPeminjaman({
    required int peminjamanId,
    required int alatId,
    String? kondisiSaatPinjam,
  }) async {
    try {
      final response = await _supabase
          .from('detail_peminjaman')
          .insert({
            'peminjaman_id': peminjamanId,
            'alat_id': alatId,
            'kondisi_saat_pinjam': kondisiSaatPinjam,
          })
          .select('*, alat:alat(*)')
          .limit(1);

      final list = response as List<dynamic>;
      if (list.isEmpty) throw Exception('Failed to create detail peminjaman');
      return DetailPeminjaman.fromJson(list.first);
    } catch (e) {
      print("ERROR CREATE DETAIL PEMINJAMAN: $e");
      rethrow;
    }
  }

  Future<bool> updateDetailPeminjaman({
    required int id,
    String? kondisiSaatKembali,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (kondisiSaatKembali != null) updateData['kondisi_saat_kembali'] = kondisiSaatKembali;

      await _supabase.from('detail_peminjaman').update(updateData).eq('id', id);

      return true;
    } catch (e) {
      print("ERROR UPDATE DETAIL PEMINJAMAN: $e");
      return false;
    }
  }
}
