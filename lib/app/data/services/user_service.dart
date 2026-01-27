import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import '../models/AppUser.dart';
import '../models/AppRole.dart';

class UserService {
  final SupabaseClient _supabase = AuthService().client;

  Future<AppUser?> getProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await _supabase
        .from('profil_pengguna')
        .select()
        .eq('id', userId)
        .single();

    int roleId = 3;
    if (data['peran'] == 'admin') roleId = 1;
    if (data['peran'] == 'petugas') roleId = 2;

    return AppUser(
      id: data['id'], // UUID STRING
      peranId: roleId,
      inst: 'Unknown',
      nama: data['nama_lengkap'],
      email: '',
      pass: '',
      role: AppRole(id: roleId, peran: data['peran']),
    );
  }

  Future<void> insertProfile({
    required String userId,
    required String nama,
    required String peran,
  }) async {
    await _supabase.from('profil_pengguna').insert({
      'id': userId,
      'nama_lengkap': nama,
      'peran': peran,
    });
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await _supabase.from('profil_pengguna').select();
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _supabase.from('profil_pengguna').update(data).eq('id', id);
  }

  Future<void> deleteUser(String id) async {
    await _supabase.from('profil_pengguna').delete().eq('id', id);
  }
}
