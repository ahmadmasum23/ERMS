class AppUser {
  final String id;
  final int peranId;
  final String nama;
  final String email;
  final String pass;
  final String? alamat;
  final String? nomorHp;

  AppUser({
    required this.id,
    required this.peranId,
    required this.nama,
    required this.email,
    required this.pass,
    this.alamat,
    this.nomorHp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'peran': _mapIdToRole(peranId), // ⬅️ UBAH DI SINI
      'nama_lengkap': nama,
      'email': email,
      'alamat': alamat,
      'nomor_hp': nomorHp,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      peranId: _mapRoleToId(json['peran']),
      nama: json['nama_lengkap']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      pass: '',
      alamat: json['alamat']?.toString(),
      nomorHp: json['nomor_hp']?.toString(),
    );
  }

  /// DB → APP
  static int _mapRoleToId(dynamic role) {
    switch (role?.toString()) {
      case 'admin':
        return 1;
      case 'petugas':
        return 2;
      case 'peminjam':
        return 3;
      default:
        return 0;
    }
  }

  /// APP → DB
  static String _mapIdToRole(int id) {
    switch (id) {
      case 1:
        return 'admin';
      case 2:
        return 'petugas';
      case 3:
        return 'peminjam';
      default:
        return 'peminjam';
    }
  }
}
