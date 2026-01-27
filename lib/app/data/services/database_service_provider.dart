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

  static Future<bool> register({
    required String email,
    required String password,
    required String nama,
    required String peran,
  }) async {
    final user = await _auth.register(email, password);
    if (user == null) return false;

    await _user.insertProfile(
      userId: user.id,
      nama: nama,
      peran: peran,
    );
    return true;
  }

  static Future<void> logout() => _auth.logout();

  static bool get isAuthenticated => _auth.isLoggedIn;

  static String? get currentUserId => _auth.currentUserId;
}
