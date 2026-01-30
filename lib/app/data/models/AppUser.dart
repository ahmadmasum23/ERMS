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
      'id_peran': peranId,
      'nama_lengkap': nama,
      'email': email,
      'password': pass,
      'alamat': alamat,
      'nomor_hp': nomorHp,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      peranId: _mapRoleToId(json['peran']),
      // peranId: int.tryParse(json['peran']?.toString() ?? '0') ?? 0,
      nama: json['nama_lengkap']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      pass: '',
      alamat: json['alamat']?.toString(),
      nomorHp: json['nomor_hp']?.toString(),
    );
  }

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
}
