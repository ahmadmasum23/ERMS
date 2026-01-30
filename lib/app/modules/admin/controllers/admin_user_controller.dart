import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/data/models/AppUser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/database_service_provider.dart';

class AdminUserController extends GetxController {
  final UserService _userService = UserService();

  var users = <AppUser>[].obs;
  var isLoading = false.obs;
  var selectedRole = 'semua'.obs;

  @override
  void onInit() {
    fetchUsers();
    super.onInit();
  }

  // ================= FETCH USERS =================
  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;

      final response = await Supabase.instance.client
          .from('vw_user_with_email')
          .select();

      print("DEBUG - USERS: $response");

      users.value = (response as List)
          .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      users.clear();
      Get.snackbar(
        "Error",
        "Gagal mengambil data user",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      print("ERROR FETCH USER: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ================= ADD USER =================
  Future<bool> addUser({
    required String email,
    required String password,
    required String nama,
    required String peran,
    required String alamat,
    required String nomorHp,
  }) async {
    try {
      isLoading.value = true;

      await DatabaseServiceProvider.register(
        email: email,
        password: password,
        nama: nama,
        peran: peran,
        alamat: alamat,
        nomorHp: nomorHp,
      );

      await fetchUsers();
      
      Get.snackbar(
        "✓ Berhasil",
        "User '$nama' berhasil ditambahkan",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
        duration: Duration(seconds: 3),
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        "✗ Gagal",
        "Gagal menambah user. Email mungkin sudah terdaftar.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      print("ERROR ADD USER: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ================= UPDATE USER =================
  Future<bool> updateUser({
    required String userId,
    required String nama,
    required String email,
    required String peran,
    required String alamat,
    required String nomorHp,
  }) async {
    try {
      isLoading.value = true;

      // Convert role string to peran_id integer
      final peranId = _roleToId(peran);

      // Build update data
      final updateData = {
        'nama_lengkap': nama,
        'email': email,
        'id_peran': peranId,
        'alamat': alamat,
        'nomor_hp': nomorHp,
      };

      // Update user data
      await Supabase.instance.client
          .from('users')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      await fetchUsers();
      
      Get.snackbar(
        "✓ Berhasil",
        "Data user '$nama' berhasil diperbarui",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
        duration: Duration(seconds: 3),
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        "✗ Gagal",
        "Gagal memperbarui user. Coba lagi nanti.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      print("ERROR UPDATE USER: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ================= DELETE USER =================
  Future<bool> deleteUser(String userId) async {
    try {
      isLoading.value = true;

      // Delete user from auth first
      await Supabase.instance.client.auth.admin.deleteUser(userId);

      // Then delete from users table
      await Supabase.instance.client
          .from('users')
          .delete()
          .eq('id', userId);

      await fetchUsers();
      
      Get.snackbar(
        "✓ Berhasil",
        "User berhasil dihapus",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
        duration: Duration(seconds: 3),
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        "✗ Gagal",
        "Gagal menghapus user. Coba lagi nanti.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      print("ERROR DELETE USER: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ================= HELPERS =================
  String _roleName(int id) =>
      {1: 'admin', 2: 'petugas', 3: 'peminjam'}[id] ?? 'unknown';

  int _roleToId(String role) =>
      {'admin': 1, 'petugas': 2, 'peminjam': 3}[role] ?? 3;

  String getRoleNameById(int id) => _roleName(id);
  int getRoleIdByName(String role) => _roleToId(role);
}