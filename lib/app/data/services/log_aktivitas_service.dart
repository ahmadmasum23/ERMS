import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import '../models/LogAktivitas.dart';

class LogAktivitasService {
  final SupabaseClient _supabase = AuthService().client;

  Future<List<LogAktivitas>> getAllLogs() async {
    try {
      final response = await _supabase
          .from('log_aktivitas')
          .select('*')
          .order('dibuat_pada', ascending: false);
      
      return response.map((e) => LogAktivitas.fromJson(e)).toList();
    } catch (e) {
      print("ERROR FETCH ALL LOGS: $e");
      rethrow;
    }
  }

  Future<List<LogAktivitas>> getLogsByUser(String userId) async {
    try {
      final response = await _supabase
          .from('log_aktivitas')
          .select('*')
          .eq('pengguna_id', userId)
          .order('dibuat_pada', ascending: false);
      
      return response.map((e) => LogAktivitas.fromJson(e)).toList();
    } catch (e) {
      print("ERROR FETCH LOGS BY USER: $e");
      rethrow;
    }
  }

  Future<List<LogAktivitas>> getLogsByEntity(String entitas) async {
    try {
      final response = await _supabase
          .from('log_aktivitas')
          .select('*')
          .eq('entitas', entitas)
          .order('dibuat_pada', ascending: false);
      
      return response.map((e) => LogAktivitas.fromJson(e)).toList();
    } catch (e) {
      print("ERROR FETCH LOGS BY ENTITY: $e");
      rethrow;
    }
  }

  Future<LogAktivitas> createLog({
    String? penggunaId,
    required String aksi,
    required String entitas,
    int? entitasId,
    Map<String, dynamic>? nilaiLama,
    Map<String, dynamic>? nilaiBaru,
    String? namaPengguna,
    String? peranPengguna,
    List<String>? kolomDiubah,
  }) async {
    try {
      final response = await _supabase
          .from('log_aktivitas')
          .insert({
            'pengguna_id': penggunaId,
            'aksi': aksi,
            'entitas': entitas,
            'entitas_id': entitasId,
            'nilai_lama': nilaiLama,
            'nilai_baru': nilaiBaru,
            'nama_pengguna': namaPengguna,
            'peran_pengguna': peranPengguna,
            'kolom_diubah': kolomDiubah,
          })
          .select('*')
          .limit(1);
      
      if (response.isEmpty) throw Exception('Failed to create log');
      return LogAktivitas.fromJson(response.first);
    } catch (e) {
      print("ERROR CREATE LOG: $e");
      rethrow;
    }
  }

  // Alias for createLog
  Future<LogAktivitas> insertLog({
    String? penggunaId,
    required String aksi,
    required String entitas,
    int? entitasId,
    Map<String, dynamic>? nilaiLama,
    Map<String, dynamic>? nilaiBaru,
    String? namaPengguna,
    String? peranPengguna,
    List<String>? kolomDiubah,
  }) async {
    return createLog(
      penggunaId: penggunaId,
      aksi: aksi,
      entitas: entitas,
      entitasId: entitasId,
      nilaiLama: nilaiLama,
      nilaiBaru: nilaiBaru,
      namaPengguna: namaPengguna,
      peranPengguna: peranPengguna,
      kolomDiubah: kolomDiubah,
    );
  }

  Future<bool> deleteLog(int id) async {
    try {
      await _supabase
          .from('log_aktivitas')
          .delete()
          .eq('id', id);
      
      return true;
    } catch (e) {
      print("ERROR DELETE LOG: $e");
      return false;
    }
  }
}