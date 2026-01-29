class AppUser {
  final String id;
  final int peranId;
  final String nama;
  final String email;
  final String pass;

  AppUser({
    required this.id,
    required this.peranId,
    required this.nama,
    required this.email,
    required this.pass,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_peran': peranId,
      'nama': nama,
      'email': email,
      'password': pass,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      peranId: int.tryParse(json['peran']?.toString() ?? '0') ?? 0,
      nama: json['nama_lengkap']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      pass: '',
    );
  }
}
