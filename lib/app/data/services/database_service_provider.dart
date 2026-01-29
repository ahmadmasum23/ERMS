import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/AppUser.dart';
import 'auth_service.dart';
import 'user_service.dart';

class DatabaseServiceProvider {
  static final AuthService _auth = AuthService();
  static final UserService _user = UserService();

  static Future<void> initialize() async => _auth.init();

  static Future<AppUser?> login(String email, String password) async {
    final user = await _auth.login(email, password);
    if (user == null) return null;
    return await _user.getProfile();
  }

  static Future<void> register({
  required String email,
  required String password,
  required String nama,
  required String peran,
  required String alamat,
  required String nomorHp,
}) async {
  final supabase = Supabase.instance.client;

  final auth = await supabase.auth.signUp(
    email: email,
    password: password,
  );

  final user = auth.user;
  if (user == null) throw Exception("User gagal dibuat");

  await supabase.from('profil_pengguna').insert({
    'id': user.id,
    'nama_lengkap': nama,
    'peran': peran,
    'alamat': alamat,
    'nomor_hp': nomorHp,
  });
}


  static Future<void> logout() => _auth.logout();

  static bool get isAuthenticated => _auth.isLoggedIn;

  static String? get currentUserId => _auth.currentUserId;
}
