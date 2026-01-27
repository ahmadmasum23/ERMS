import 'AppPengajuan.dart';
import 'AppRole.dart';

class AppUser {
  final String id; 
  final int peranId;
  final String inst;
  final String nama;
  final String email;
  final String pass;

  final AppRole? role;
  final AppPengajuan? pengajuan;

  AppUser({
    required this.id,
    required this.peranId,
    required this.inst,
    required this.nama,
    required this.email,
    required this.pass,
    this.role,
    this.pengajuan,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_peran': peranId,
      'nama': nama,
      'instansi': inst,
      'email': email,
      'password': pass,
      'role': role?.toJson(),
      'pengajuan': pengajuan?.toJson(),
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'].toString(), 
      peranId: int.tryParse(json['id_peran'].toString()) ?? 0,
      nama: json['nama'] ?? '',
      inst: json['instansi'] ?? '',
      email: json['email'] ?? '',
      pass: json['password'] ?? '',
      role: json['role'] != null ? AppRole.fromJson(json['role']) : null,
      pengajuan: json['pengajuan'] != null
          ? AppPengajuan.fromJson(json['pengajuan'])
          : null,
    );
  }
}
