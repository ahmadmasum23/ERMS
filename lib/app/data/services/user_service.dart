import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import '../models/ProfilPengguna.dart';

class UserService {
  final SupabaseClient _supabase = AuthService().client;

  Future<ProfilPengguna?> getProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('profil_pengguna')
        .select()
        .eq('id', userId)
        .limit(1);
    
    if (response.isEmpty) return null;
    final data = response.first;

    return ProfilPengguna.fromJson(data);
  }

  Future<void> insertProfile({
    required String userId,
    required String namaLengkap,
    required String peran,
    String? alamat,
    String? nomorHp,
  }) async {
    await _supabase.from('profil_pengguna').insert({
      'id': userId,
      'nama_lengkap': namaLengkap,
      'peran': peran,
      'alamat': alamat,
      'nomor_hp': nomorHp,
    });
  }

  Future<List<ProfilPengguna>> getAllUsers() async {
    final response = await _supabase.from('profil_pengguna').select();
    return response.map((data) => ProfilPengguna.fromJson(data)).toList();
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _supabase.from('profil_pengguna').update(data).eq('id', id);
  }

  Future<void> deleteUser(String id) async {
    await _supabase.from('profil_pengguna').delete().eq('id', id);
  }
}
