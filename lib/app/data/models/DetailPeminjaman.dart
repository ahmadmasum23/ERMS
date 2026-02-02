import 'Alat.dart';

class DetailPeminjaman {
  final int id;
  final int peminjamanId;
  final int alatId;
  final String? kondisiSaatPinjam;
  final String? kondisiSaatKembali;
  final DateTime? dibuatPada;
  
  // Relations
  final Alat? alat;

  DetailPeminjaman({
    required this.id,
    required this.peminjamanId,
    required this.alatId,
    this.kondisiSaatPinjam,
    this.kondisiSaatKembali,
    this.dibuatPada,
    this.alat,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'peminjaman_id': peminjamanId,
      'alat_id': alatId,
      'kondisi_saat_pinjam': kondisiSaatPinjam,
      'kondisi_saat_kembali': kondisiSaatKembali,
      'dibuat_pada': dibuatPada?.toIso8601String(),
    };
  }

  factory DetailPeminjaman.fromJson(Map<String, dynamic> json) {
    return DetailPeminjaman(
      id: int.parse(json['id'].toString()),
      peminjamanId: int.parse(json['peminjaman_id'].toString()),
      alatId: int.parse(json['alat_id'].toString()),
      kondisiSaatPinjam: json['kondisi_saat_pinjam'],
      kondisiSaatKembali: json['kondisi_saat_kembali'],
      dibuatPada: json['dibuat_pada'] != null
          ? DateTime.parse(json['dibuat_pada'])
          : null,
      alat: json['alat'] != null
          ? Alat.fromJson(json['alat'])
          : null,
    );
  }
}