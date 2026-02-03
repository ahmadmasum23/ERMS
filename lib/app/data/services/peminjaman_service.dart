import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import '../models/Peminjaman.dart';
import '../models/DetailPeminjaman.dart';
import '../models/ProfilPengguna.dart';

class PeminjamanService {
  final SupabaseClient _supabase = AuthService().client;

  Future<List<Peminjaman>> getAllPeminjaman() async {
    try {
      final response = await _supabase
          .from('peminjaman')
          .select('*, peminjam:profil_pengguna!peminjaman_peminjam_id_fkey(*), petugas:profil_pengguna!peminjaman_disetujui_oleh_fkey(*)')
          .order('tanggal_pinjam', ascending: false);
      
      return (response as List)
          .map((e) => Peminjaman.fromJson(e))
          .toList();
    } catch (e) {
      print("ERROR FETCH ALL PEMINJAMAN: $e");
      rethrow;
    }
  }

  Future<List<Peminjaman>> getPeminjamanByUser(String userId) async {
    try {
      final response = await _supabase
          .from('peminjaman')
          .select('*, peminjam:profil_pengguna!peminjaman_peminjam_id_fkey(*), petugas:profil_pengguna!peminjaman_disetujui_oleh_fkey(*)')
          .eq('peminjam_id', userId)
          .order('tanggal_pinjam', ascending: false);
      
      return (response as List)
          .map((e) => Peminjaman.fromJson(e))
          .toList();
    } catch (e) {
      print("ERROR FETCH PEMINJAMAN BY USER: $e");
      rethrow;
    }
  }

  Future<List<DetailPeminjaman>> getDetailByPeminjaman(int peminjamanId) async {
    final result = await _supabase
        .from('detail_peminjaman')
        .select('*, alat:alat(*)')
        .eq('peminjaman_id', peminjamanId);
    
    return (result as List)
        .map((e) => DetailPeminjaman.fromJson(e))
        .toList();
  }

  Future<Peminjaman?> getPeminjamanById(int id) async {
    try {
      final response = await _supabase
          .from('peminjaman')
          .select('*, peminjam:profil_pengguna!peminjaman_peminjam_id_fkey(*), petugas:profil_pengguna!peminjaman_disetujui_oleh_fkey(*)')
          .eq('id', id)
          .limit(1);
      
      if ((response as List).isEmpty) return null;
      return Peminjaman.fromJson(response.first);
    } catch (e) {
      print("ERROR FETCH PEMINJAMAN BY ID: $e");
      return null;
    }
  }

  Future<Peminjaman> createPeminjaman({
    required String peminjamId,
    required DateTime tanggalPinjam,
    required DateTime tanggalJatuhTempo,
    required String status,
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
      
      if ((response as List).isEmpty) throw Exception('Failed to create peminjaman');
      return Peminjaman.fromJson(response.first);
    } catch (e) {
      print("ERROR CREATE PEMINJAMAN: $e");
      rethrow;
    }
  }

 Future<bool> updatePeminjaman({
  required int id,
  String? disetujuiOleh,
  DateTime? tanggalKembali,
  String? status,
  int? hariTerlambat,
  String? alasan,
}) async {
  try {
    if (id == 0) {
      print("ERROR: id peminjaman = 0");
      return false;
    }

    final Map<String, dynamic> updateData = {};
    if (disetujuiOleh != null) updateData['disetujui_oleh'] = disetujuiOleh;
    if (tanggalKembali != null) updateData['tanggal_kembali'] = tanggalKembali.toIso8601String();
    if (status != null) updateData['status'] = status.toLowerCase(); // pastikan lowercase
    if (hariTerlambat != null) updateData['hari_terlambat'] = hariTerlambat;
    if (alasan != null) updateData['alasan'] = alasan;

    print("DEBUG UPDATE PEMINJAMAN: id=$id, data=$updateData");

    // update tanpa execute()
    final response = await _supabase
        .from('peminjaman')
        .update(updateData)
        .eq('id', id)
        .select(); // bisa ambil row updated jika mau

    if (response == null || (response as List).isEmpty) {
      print("UPDATE PEMINJAMAN GAGAL: row tidak ditemukan atau tidak diupdate");
      return false;
    }

    print("UPDATE PEMINJAMAN BERHASIL: $response");
    return true;
  } catch (e) {
    print("ERROR UPDATE PEMINJAMAN EXCEPTION: $e");
    return false;
  }
}


  Future<bool> deletePeminjaman(int id) async {
    try {
      await _supabase
          .from('peminjaman')
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      print("ERROR DELETE PEMINJAMAN: $e");
      return false;
    }
  }

  Future<List<DetailPeminjaman>> getDetailPeminjaman(int peminjamanId) async {
    try {
      final response = await _supabase
          .from('detail_peminjaman')
          .select('*, alat:alat(*)')
          .eq('peminjaman_id', peminjamanId);
      
      return (response as List)
          .map((e) => DetailPeminjaman.fromJson(e))
          .toList();
    } catch (e) {
      print("ERROR FETCH DETAIL PEMINJAMAN: $e");
      rethrow;
    }
  }

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
      
      if ((response as List).isEmpty) throw Exception('Failed to create detail peminjaman');
      return DetailPeminjaman.fromJson(response.first);
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

      await _supabase
          .from('detail_peminjaman')
          .update(updateData)
          .eq('id', id);
      
      return true;
    } catch (e) {
      print("ERROR UPDATE DETAIL PEMINJAMAN: $e");
      return false;
    }
  }
}
