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
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildRoleFilter()),
                    const SizedBox(width: 12),
                    _addButton(isMobile),
                  ],
                ),
                const SizedBox(height: 20),

                /// 🔥 LIST USER REALTIME
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final users = controller.users.where((u) {
                      if (controller.selectedRole.value == 'semua') return true;
                      return _roleName(u.peranId) ==
                          controller.selectedRole.value;
                    }).toList();

                    if (users.isEmpty) {
                      return const Center(child: Text("Tidak ada user"));
                    }

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return isMobile
                            ? _buildUserCardMobile(user, context)
                            : _buildUserRowDesktop(user, context);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= HEADER =================
  Widget _header(BuildContext context, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Management',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Kelola data pengguna sistem',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        if (!isMobile) _addButton(false),
      ],
    );
  }

  Widget _addButton(bool isMobile) {
    return SizedBox(
      width: isMobile ? 120 : 140,
      child: ElevatedButton.icon(
        onPressed: () => _showAddUserDialog(),
        icon: const Icon(Icons.add, size: 18),
        label: Text(
          'Tambah User',
          style: TextStyle(fontSize: isMobile ? 12 : 14),
        ),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
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
        title: const Text("Tambah User Baru"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nama"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Nama wajib diisi" : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Email wajib diisi" : null,
              ),
              TextFormField(
                controller: passController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty
                    ? "Password wajib diisi"
                    : null,
              ),
              TextFormField(
  controller: alamatController,
  decoration: const InputDecoration(labelText: "Alamat"),
  validator: (v) => v == null || v.isEmpty ? "Alamat wajib diisi" : null,
),
TextFormField(
  controller: hpController,
  decoration: const InputDecoration(labelText: "Nomor HP"),
  keyboardType: TextInputType.phone,
  validator: (v) => v == null || v.isEmpty ? "Nomor HP wajib diisi" : null,
),

              const SizedBox(height: 10),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: selectedRole.value,
                  decoration: const InputDecoration(labelText: "Role"),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text("Admin")),
                    DropdownMenuItem(value: 'petugas', child: Text("Petugas")),
                    DropdownMenuItem(
                      value: 'peminjam',
                      child: Text("Peminjam"),
                    ),
                  ],
                  onChanged: (v) => selectedRole.value = v!,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
  if (_formKey.currentState!.validate()) {
    controller.addUser(
      nama: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passController.text.trim(),
      peran: selectedRole.value,
      alamat: alamatController.text.trim(),
      nomorHp: hpController.text.trim(),
    );
    Get.back();
  }
},

            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ================= FILTER =================
  Widget _buildRoleFilter() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedRole.value,
            items: const [
              DropdownMenuItem(value: 'semua', child: Text('Semua Role')),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
              DropdownMenuItem(value: 'petugas', child: Text('Petugas')),
              DropdownMenuItem(value: 'peminjam', child: Text('Peminjam')),
            ],
            onChanged: (v) => controller.selectedRole.value = v!,
          ),
        ),
      ),
    );
  }

  // ================= MOBILE CARD =================
  Widget _buildUserCardMobile(AppUser user, BuildContext context) {
    final role = _roleName(user.peranId);
    final roleColor = _roleColor(role);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _avatar(user.nama),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              _actions(user),
            ],
          ),
          const SizedBox(height: 8),
          _infoRow(Icons.person_outline, role, roleColor),
        ],
      ),
    );
  }

  // ================= DESKTOP ROW =================
  Widget _buildUserRowDesktop(AppUser user, BuildContext context) {
    final role = _roleName(user.peranId);
    final roleColor = _roleColor(role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _avatar(user.nama),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: Text(user.nama)),
          Expanded(flex: 3, child: Text(user.email)),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                role,
                textAlign: TextAlign.center,
                style: TextStyle(color: roleColor),
              ),
            ),
          ),
          _actions(user),
        ],
      ),
    );
  }

  // ================= HELPERS =================
  Widget _avatar(String? name) => Container(
    width: 32,
    height: 32,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(_initials(name), style: const TextStyle(color: Colors.white)),
  );

  Widget _actions(AppUser user) => Row(
    children: [
      IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () {}),
      IconButton(
        icon: const Icon(Icons.delete, size: 18),
        onPressed: () => controller.deleteUser(user.id),
      ),
    ],
  );

  Widget _infoRow(IconData icon, String text, Color color) => Row(
    children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 10)),
      ),
    ],
  );

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return "?";

    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();

    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _roleName(int id) =>
      {1: 'admin', 2: 'petugas', 3: 'peminjam'}[id] ?? 'unknown';

  Color _roleColor(String role) => role == 'admin'
      ? Colors.purple
      : role == 'petugas'
      ? Colors.green
      : Colors.blue;
}
