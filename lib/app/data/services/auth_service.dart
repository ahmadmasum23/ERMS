import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/database_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  late final SupabaseClient _supabase;

  Future<void> init() async {
    await Supabase.initialize(
      url: DatabaseConfig.supabaseUrl,
      anonKey: DatabaseConfig.supabaseAnonKey,
    );
    _supabase = Supabase.instance.client;
  }

  SupabaseClient get client => _supabase;

  Future<User?> login(String email, String password) async {
    final res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return res.user;
  }

  Future<User?> register(String email, String password) async {
    final res = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    return res.user;
  }

  Future<void> logout() async => _supabase.auth.signOut();

  bool get isLoggedIn => _supabase.auth.currentUser != null;

  String? get currentUserId => _supabase.auth.currentUser?.id;
}
