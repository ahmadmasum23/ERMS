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
    Get.snackbar("Error", "Gagal mengambil user");
    print("ERROR FETCH USER: $e");
  } finally {
    isLoading.value = false;
  }
}

  Future<void> addUser({
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
    Get.snackbar("Berhasil", "User berhasil ditambahkan");
  } catch (e) {
    Get.snackbar("Error", "Gagal tambah user");
    print("ERROR ADD USER: $e");
  } finally {
    isLoading.value = false;
  }
}


  Future<void> deleteUser(String id) async {
    await _userService.deleteUser(id);
    fetchUsers();
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _userService.updateUser(id, data);
    fetchUsers();
  }
}
