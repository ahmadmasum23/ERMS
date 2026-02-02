import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inven/app/data/models/AppLogAktivitas.dart';
import 'auth_service.dart';

class LogAktivitasService {
  final SupabaseClient _supabase = AuthService().client;

  /// Fetch all activity logs with user details
  Future<List<AppLogAktivitas>> getAllLogs() async {
    try {
      // Try the join query first
      List response;
      try {
        response = await _supabase
            .from('log_aktivitas')
            .select('*, profil_pengguna!inner(nama_lengkap, peran)')
            .order('dibuat_pada', ascending: false)
            .limit(100);
      } catch (e) {
        print("INNER JOIN query failed, falling back to separate queries: $e");
        // Fallback: fetch logs and user details separately
        response = await _supabase
            .from('log_aktivitas')
            .select('*')
            .order('dibuat_pada', ascending: false)
            .limit(100);
      }

      // Process the response
      List<AppLogAktivitas> logs = [];
      
      if (response.isNotEmpty) {
        for (var item in response) {
          Map<String, dynamic> processedItem = Map<String, dynamic>.from(item);
          
          // If the item contains profil_pengguna (from join), flatten it
          if (processedItem.containsKey('profil_pengguna')) {
            var profilData = processedItem['profil_pengguna'];
            if (profilData != null && profilData is Map<String, dynamic>) {
              processedItem['nama_lengkap'] = profilData['nama_lengkap'];
              processedItem['peran'] = profilData['peran'];
            }
          }
          
          logs.add(AppLogAktivitas.fromJson(processedItem));
        }
      }
      
      return logs;
    } catch (e) {
      print("ERROR FETCH LOG AKTIVITAS: $e");
      rethrow;
    }
  }

  /// Insert a new activity log
  Future<void> insertLog({
    required String aksi,
    required String entitas,
    String? penggunaId,
    int? entitasId,
    Map<String, dynamic>? nilaiLama,
    Map<String, dynamic>? nilaiBaru,
  }) async {
    try {
      // If no user ID provided, use current authenticated user
      final userId = penggunaId ?? _supabase.auth.currentUser?.id;

      await _supabase.from('log_aktivitas').insert({
        'pengguna_id': userId,
        'aksi': aksi,
        'entitas': entitas,
        'entitas_id': entitasId,
        'nilai_lama': nilaiLama,
        'nilai_baru': nilaiBaru,
      });
    } catch (e) {
      print("ERROR INSERT LOG AKTIVITAS: $e");
      // Don't rethrow to prevent app crashes on logging failures
    }
  }

  /// Get logs for a specific user
  Future<List<AppLogAktivitas>> getLogsByUser(String userId) async {
    try {
      List response;
      try {
        response = await _supabase
            .from('log_aktivitas')
            .select('*, profil_pengguna!inner(nama_lengkap, peran)')
            .eq('pengguna_id', userId)
            .order('dibuat_pada', ascending: false);
      } catch (e) {
        print("INNER JOIN query failed for getLogsByUser: $e");
        response = await _supabase
            .from('log_aktivitas')
            .select('*')
            .eq('pengguna_id', userId)
            .order('dibuat_pada', ascending: false);
      }

      // Process the response
      List<AppLogAktivitas> logs = [];
      
      if (response.isNotEmpty) {
        for (var item in response) {
          Map<String, dynamic> processedItem = Map<String, dynamic>.from(item);
          
          // If the item contains profil_pengguna (from join), flatten it
          if (processedItem.containsKey('profil_pengguna')) {
            var profilData = processedItem['profil_pengguna'];
            if (profilData != null && profilData is Map<String, dynamic>) {
              processedItem['nama_lengkap'] = profilData['nama_lengkap'];
              processedItem['peran'] = profilData['peran'];
            }
          }
          
          logs.add(AppLogAktivitas.fromJson(processedItem));
        }
      }
      
      return logs;
    } catch (e) {
      print("ERROR FETCH USER LOGS: $e");
      rethrow;
    }
  }

  /// Get logs for a specific entity
  Future<List<AppLogAktivitas>> getLogsByEntity(String entitas, int entitasId) async {
    try {
      List response;
      try {
        response = await _supabase
            .from('log_aktivitas')
            .select('*, profil_pengguna!inner(nama_lengkap, peran)')
            .eq('entitas', entitas)
            .eq('entitas_id', entitasId)
            .order('dibuat_pada', ascending: false);
      } catch (e) {
        print("INNER JOIN query failed for getLogsByEntity: $e");
        response = await _supabase
            .from('log_aktivitas')
            .select('*')
            .eq('entitas', entitas)
            .eq('entitas_id', entitasId)
            .order('dibuat_pada', ascending: false);
      }

      // Process the response
      List<AppLogAktivitas> logs = [];
      
      if (response.isNotEmpty) {
        for (var item in response) {
          Map<String, dynamic> processedItem = Map<String, dynamic>.from(item);
          
          // If the item contains profil_pengguna (from join), flatten it
          if (processedItem.containsKey('profil_pengguna')) {
            var profilData = processedItem['profil_pengguna'];
            if (profilData != null && profilData is Map<String, dynamic>) {
              processedItem['nama_lengkap'] = profilData['nama_lengkap'];
              processedItem['peran'] = profilData['peran'];
            }
          }
          
          logs.add(AppLogAktivitas.fromJson(processedItem));
        }
      }
      
      return logs;
    } catch (e) {
      print("ERROR FETCH ENTITY LOGS: $e");
      rethrow;
    }
  }
}