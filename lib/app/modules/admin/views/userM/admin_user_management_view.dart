import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/data/models/AppUser.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';
import 'package:inven/app/modules/admin/controllers/admin_user_controller.dart';

class AdminUserManagementView extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  AdminUserManagementView({Key? key, required this.scaffoldKey})
    : super(key: key);

  final AdminUserController controller = Get.put(AdminUserController());

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;

    return Column(
      children: [
        CustomAppbar(
          title: 'User Management',
          boldTitle: 'Panel',
          showNotif: false,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, isMobile),
                const SizedBox(height: 16),
                _buildFilterSection(isMobile),
                const SizedBox(height: 16),
                _buildUserList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 17 : 19,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Kelola data pengguna sistem',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: isMobile ? 12 : 13,
              ),
            ),
          ],
        ),
        if (!isMobile) _buildAddButton(false),
      ],
    );
  }

  Widget _buildFilterSection(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(Icons.filter_list, size: 19, color: Colors.grey[700]),
                const SizedBox(width: 10),
                const Text(
                  'Filter Role:',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(child: _buildRoleFilter()),
              ],
            ),
          ),
          if (isMobile) ...[
            const SizedBox(width: 14),
            _buildAddButton(isMobile),
          ],
        ],
      ),
    );
  }

  Widget _buildAddButton(bool isMobile) {
    return SizedBox(
      width: isMobile ? 125 : 145,
      height: 40,
      child: ElevatedButton.icon(
        onPressed: () => _showAddUserDialog(),
        icon: const Icon(Icons.add, size: 17),
        label: Text(
          'Tambah User',
          style: TextStyle(fontSize: isMobile ? 12.5 : 13.5),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildRoleFilter() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: controller.selectedRole.value,
            items: const [
              DropdownMenuItem(
                value: 'semua',
                child: Text('Semua Role', style: TextStyle(fontSize: 13)),
              ),
              DropdownMenuItem(
                value: 'admin',
                child: Text('Admin', style: TextStyle(fontSize: 13)),
              ),
              DropdownMenuItem(
                value: 'petugas',
                child: Text('Petugas', style: TextStyle(fontSize: 13)),
              ),
              DropdownMenuItem(
                value: 'peminjam',
                child: Text('Peminjam', style: TextStyle(fontSize: 13)),
              ),
            ],
            onChanged: (v) => controller.selectedRole.value = v!,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        final users = controller.users.where((u) {
          if (controller.selectedRole.value == 'semua') return true;
          return controller.getRoleNameById(u.peranId) ==
              controller.selectedRole.value;
        }).toList();

        if (users.isEmpty) {
          return _emptyState();
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildUserItem(user, context);
          },
        );
      }),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 14),
          Text(
            "Tidak ada user ditemukan",
            style: TextStyle(
              fontSize: 17,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Coba ubah filter role atau tambah user baru",
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(AppUser user, BuildContext context) {
    final role = controller.getRoleNameById(user.peranId);
    final roleColor = _roleColor(role);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xffF4F7F7),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      user.nama.isNotEmpty ? user.nama[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nama,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.edit,
                        size: 17,
                        color: Colors.blue,
                      ),
                      onPressed: () => _showEditUserDialog(user),
                    ),
                    const SizedBox(height: 2),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.delete,
                        size: 17,
                        color: Colors.red,
                      ),
                      onPressed: () => _confirmDeleteUser(user),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 17,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.nomorHp ?? '-',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    role.toLowerCase(),
                    style: TextStyle(
                      fontSize: 13,
                      color: roleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 13,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    user.alamat ?? '-',
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog() {
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passController = TextEditingController();
    final alamatController = TextEditingController();
    final hpController = TextEditingController();
    final selectedRole = 'admin'.obs;

    Get.dialog(
      AlertDialog(
        title: const Text("Tambah User Baru", style: TextStyle(fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogField(
                    controller: nameController,
                    label: "Nama",
                    validator: (v) =>
                        v?.isEmpty ?? true ? "Nama wajib diisi" : null,
                  ),
                  _buildDialogField(
                    controller: emailController,
                    label: "Email",
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v?.isEmpty ?? true
                        ? "Email wajib diisi"
                        : !GetUtils.isEmail(v!)
                        ? "Format email tidak valid"
                        : null,
                  ),
                  _buildDialogField(
                    controller: passController,
                    label: "Password",
                    obscureText: true,
                    validator: (v) => (v?.length ?? 0) < 6
                        ? "Password minimal 6 karakter"
                        : null,
                  ),
                  _buildDialogField(
                    controller: alamatController,
                    label: "Alamat",
                    validator: (v) =>
                        v?.isEmpty ?? true ? "Alamat wajib diisi" : null,
                  ),
                  _buildDialogField(
                    controller: hpController,
                    label: "Nomor HP",
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v?.isEmpty ?? true ? "Nomor HP wajib diisi" : null,
                  ),
                  const SizedBox(height: 14),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value: selectedRole.value,
                      decoration: InputDecoration(
                        labelText: "Role",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'admin', child: Text("Admin")),
                        DropdownMenuItem(
                          value: 'petugas',
                          child: Text("Petugas"),
                        ),
                        DropdownMenuItem(
                          value: 'peminjam',
                          child: Text("Peminjam"),
                        ),
                      ],
                      onChanged: (v) => selectedRole.value = v!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Batal", style: TextStyle(fontSize: 14)),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        final success = await controller.addUser(
                          nama: nameController.text.trim(),
                          email: emailController.text.trim(),
                          password: passController.text.trim(),
                          peran: selectedRole.value,
                          alamat: alamatController.text.trim(),
                          nomorHp: hpController.text.trim(),
                        );
                        if (success) Get.back();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(90, 36),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Simpan", style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(AppUser user) {
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.nama);
    final emailController = TextEditingController(
      text: user.email,
    ); // Read-only
    final alamatController = TextEditingController(text: user.alamat ?? '');
    final hpController = TextEditingController(text: user.nomorHp ?? '');
    final selectedRole = controller.getRoleNameById(user.peranId).obs;

    Get.dialog(
      AlertDialog(
        title: const Text("Edit User", style: TextStyle(fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogField(
                    controller: nameController,
                    label: "Nama",
                    validator: (v) =>
                        v?.isEmpty ?? true ? "Nama wajib diisi" : null,
                  ),

                  // EMAIL READ-ONLY (tidak bisa di-edit karena di auth system)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7.0),
                    child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      readOnly: true, // 🔑 EMAIL TIDAK BISA DI-EDIT
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),

                  _buildDialogField(
                    controller: alamatController,
                    label: "Alamat",
                    validator: (v) =>
                        v?.isEmpty ?? true ? "Alamat wajib diisi" : null,
                  ),
                  _buildDialogField(
                    controller: hpController,
                    label: "Nomor HP",
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v?.isEmpty ?? true ? "Nomor HP wajib diisi" : null,
                  ),
                  const SizedBox(height: 14),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value: selectedRole.value,
                      decoration: InputDecoration(
                        labelText: "Role",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'admin', child: Text("Admin")),
                        DropdownMenuItem(
                          value: 'petugas',
                          child: Text("Petugas"),
                        ),
                        DropdownMenuItem(
                          value: 'peminjam',
                          child: Text("Peminjam"),
                        ),
                      ],
                      onChanged: (v) => selectedRole.value = v!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Batal", style: TextStyle(fontSize: 14)),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        final success = await controller.updateUser(
                          userId: user.id,
                          nama: nameController.text.trim(),
                          peran: selectedRole.value,
                          alamat: alamatController.text.trim(),
                          nomorHp: hpController.text.trim(),
                        );
                        if (success) {
                          Get.back(); // Tutup dialog
                          Get.snackbar(
                            "Sukses",
                            "User berhasil diperbarui",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(12),
                            borderRadius: 8,
                            duration: const Duration(seconds: 2),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(110, 36),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Simpan Perubahan",
                      style: TextStyle(fontSize: 14),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    required FormFieldValidator<String?> validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  void _confirmDeleteUser(AppUser user) {
    Get.defaultDialog(
      title: "⚠️ Konfirmasi Hapus",
      middleText:
          "Yakin hapus user '${user.nama}'?\nTindakan ini tidak dapat dibatalkan!",
      textCancel: "Batal",
      textConfirm: "Hapus",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.black,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        await controller.deleteUser(user.id);
      },
      onCancel: () => Get.back(),
    );
  }

  Color _roleColor(String role) => role == 'admin'
      ? Colors.purple
      : role == 'petugas'
      ? Colors.green
      : Colors.blue;
}
