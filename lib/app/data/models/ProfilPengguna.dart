class ProfilPengguna {
  final String id;
  final String namaLengkap;
  final String peran; // 'admin', 'petugas', 'peminjam'
  final DateTime? dibuatPada;
  final String? alamat;
  final String? nomorHp;
  final String? email;

  ProfilPengguna({
    required this.id,
    required this.namaLengkap,
    required this.peran,
    this.dibuatPada,
    this.alamat,
    this.nomorHp,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'peran': peran,
      'dibuat_pada': dibuatPada?.toIso8601String(),
      'alamat': alamat,
      'nomor_hp': nomorHp,
      'email': email,
    };
  }

  factory ProfilPengguna.fromJson(Map<String, dynamic> json) {
    return ProfilPengguna(
      id: json['id'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      peran: json['peran'] ?? 'peminjam',
      dibuatPada: json['dibuat_pada'] != null
          ? DateTime.parse(json['dibuat_pada'])
          : null,
      alamat: json['alamat'],
      nomorHp: json['nomor_hp'],
      email: json['email'],
    );
  }
  
  // Helper getters for role checking
  bool get isAdmin => peran == 'admin';
  bool get isPetugas => peran == 'petugas';
  bool get isPeminjam => peran == 'peminjam';
}