import 'package:flutter/material.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';

class AdminUserManagementView extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AdminUserManagementView({Key? key, required this.scaffoldKey}) : super(key: key);

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
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Management',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelola data pengguna sistem',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                    // Tombol Tambah User (hanya di desktop/tablet)
                    if (!isMobile)
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tambah User')),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Tambah User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Baris Filter + Tombol Tambah User (SEJAJAR)
                  Row(
                    children: [
                      // Filter Role
                      Expanded(
                        child: _buildRoleFilter(),
                      ),
                      const SizedBox(width: 12),
                      // Tombol Tambah User (selalu muncul di sini untuk konsistensi)
                      SizedBox(
                        width: isMobile ? 120 : 140,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tambah User')),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(
                            'Tambah User',
                            style: TextStyle(fontSize: isMobile ? 12 : 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal:10 ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),

                // Daftar User
                Expanded(
                  child: ListView(
                    children: _getUserList().map((user) {
                      if (isMobile) {
                        return _buildUserCardMobile(user, context);
                      } else {
                        return _buildUserRowDesktop(user, context);
                      }
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: 'semua',
          items: const [
            DropdownMenuItem(value: 'semua', child: Text('Semua Role')),
            DropdownMenuItem(value: 'admin', child: Text('Admin')),
            DropdownMenuItem(value: 'petugas', child: Text('Petugas')),
            DropdownMenuItem(value: 'peminjam', child: Text('Peminjam')),
          ],
          onChanged: (value) {
            // TODO: Handle filter
          },
          borderRadius: BorderRadius.circular(6),
          focusColor: Colors.transparent,
          dropdownColor: Colors.white,
          style: const TextStyle(fontSize: 14, color: Colors.black),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          isDense: true,
          underline: Container(),
        ),
      ),
    );
  }

  // === MOBILE: Card Vertikal (Gaya seperti _buildLoanItem) ===
  Widget _buildUserCardMobile(User user, BuildContext context) {
    Color roleColor = Colors.grey;
    if (user.role == 'admin') roleColor = Colors.purple;
    if (user.role == 'petugas') roleColor = Colors.green;
    if (user.role == 'peminjam') roleColor = Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xffF4F7F7),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + Nama + Aksi
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    user.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Aksi Edit & Delete
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Edit ${user.name}')));
                      },
                      icon: const Icon(Icons.edit, color: Colors.black, size: 18),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hapus ${user.name}')));
                      },
                      icon: const Icon(Icons.delete, color: Colors.black, size: 18),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // No. Telp
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user.phone,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Alamat
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user.address,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Role dengan BACKGROUND SOLID
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    user.role,
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Dibuat: ${user.createdAt}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // === DESKTOP: Tabel Horizontal ===
  Widget _buildUserRowDesktop(User user, BuildContext context) {
    Color roleColor = Colors.grey.withOpacity(0.1);
    Color textColor = Colors.grey;

    if (user.role == 'admin') {
      roleColor = Colors.purple.withOpacity(0.1);
      textColor = Colors.purple;
    } else if (user.role == 'petugas') {
      roleColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green;
    } else if (user.role == 'peminjam') {
      roleColor = Colors.blue.withOpacity(0.1);
      textColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              user.initials,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(user.email, style: TextStyle(fontSize: 14, color: Colors.grey[600]))),
          Expanded(flex: 2, child: Text(user.phone, style: TextStyle(fontSize: 14, color: Colors.grey[600]))),
          Expanded(flex: 3, child: Text(user.address, style: TextStyle(fontSize: 14, color: Colors.grey[600]))),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  user.role,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
            ),
          ),
          Expanded(flex: 2, child: Text(user.createdAt, style: TextStyle(fontSize: 14, color: Colors.grey[600]))),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Edit ${user.name}')));
                  },
                  icon: const Icon(Icons.edit, color: Colors.black, size: 18),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hapus ${user.name}')));
                  },
                  icon: const Icon(Icons.delete, color: Colors.black, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<User> _getUserList() {
    return [
      User(
        'Admin Utama',
        'admin@mail.com',
        '081234567890',
        'Jl. Merdeka No. 1, Jakarta',
        'admin',
        '2024-01-10',
        'A',
      ),
      User(
        'Petugas 1',
        'petugas1@mail.com',
        '081234567891',
        'Jl. Sudirman No. 10, Bandung',
        'petugas',
        '2024-01-15',
        'P',
      ),
      User(
        'Budi Santoso',
        'budi@mail.com',
        '081234567892',
        'Jl. Diponegoro No. 5, Surabaya',
        'peminjam',
        '2024-02-01',
        'B',
      ),
      User(
        'Siti Nurhaliza',
        'siti@mail.com',
        '081234567893',
        'Jl. Gatot Subroto No. 20, Medan',
        'peminjam',
        '2024-02-05',
        'S',
      ),
      User(
        'Ahmad Dahlan',
        'ahmad@mail.com',
        '081234567894', 
        'Jl. Ahmad Yani No. 15, Makassar',
        'peminjam',
        '2024-02-10',
        'A',
      ),
    ];
  }
}

class User {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String role;
  final String createdAt;
  final String initials;

  User(this.name, this.email, this.phone, this.address, this.role, this.createdAt, this.initials);
}