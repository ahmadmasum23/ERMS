import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/data/models/AppUser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/services/database_service_provider.dart';

class AdminUserController extends GetxController {
  var users = <AppUser>[].obs;
  var isLoading = false.obs;
  var selectedRole = 'semua'.obs;

  @override
  void onInit() {
    fetchUsers();
    super.onInit();
  }

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

  Future<bool> addUser({
    required String email,
    required String password,
    required String namaLengkap,
    required String peran,
    required String alamat,
    required String nomorHp,
  }) async {
    try {
      isLoading.value = true;

      await DatabaseServiceProvider.register(
        email: email,
        password: password,
        namaLengkap: namaLengkap,
        peran: peran,
        alamat: alamat,
        nomorHp: nomorHp,
      );

      await fetchUsers();

      Get.snackbar(
        "✓ Berhasil",
        "User '$namaLengkap' berhasil ditambahkan",
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

  Future<bool> updateUser({
    required String userId,
    required String nama,
    required String peran,
    required String alamat,
    required String nomorHp,
  }) async {
    try {
      isLoading.value = true;

      final updateData = {
        'nama_lengkap': nama,
        'peran': peran,
        'alamat': alamat,
        'nomor_hp': nomorHp,
      };

      await Supabase.instance.client
          .from('profil_pengguna')
          .update(updateData)
          .eq('id', userId);

      await fetchUsers();

      Get.snackbar(
        "✓ Berhasil",
        "Data user berhasil diperbarui",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
      );

      return true;
    } catch (e) {
      print("ERROR UPDATE USER: $e");
      Get.snackbar(
        "✗ Gagal",
        "Gagal memperbarui user",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      isLoading.value = true;

      await Supabase.instance.client
          .from('profil_pengguna')
          .delete()
          .eq('id', userId);

      await fetchUsers();

      Get.snackbar(
        "✓ Berhasil",
        "User berhasil dihapus",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
      );

      return true;
    } catch (e) {
      print("ERROR DELETE USER: $e");

      Get.snackbar(
        "✗ Gagal",
        "Tidak bisa hapus user",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String _roleName(int id) =>
      {1: 'admin', 2: 'petugas', 3: 'peminjam'}[id] ?? 'unknown';

  int _roleToId(String role) =>
      {'admin': 1, 'petugas': 2, 'peminjam': 3}[role] ?? 3;

  String getRoleNameById(int id) => _roleName(id);
  int getRoleIdByName(String role) => _roleToId(role);
}
