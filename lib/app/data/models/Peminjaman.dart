  import 'ProfilPengguna.dart';
  import 'package:inven/app/data/models/DetailPeminjaman.dart';
  import 'AppPengajuan.dart';

  class Peminjaman {
    final int id;
    final String peminjamId;
    final String? disetujuiOleh;
    final DateTime tanggalPinjam;
    final DateTime tanggalJatuhTempo;
    final DateTime? tanggalKembali;
    final String status; // 'tunggu_pinjam', 'disetujui', 'ditolak', 'dikembalikan'
    final int hariTerlambat;
    final String? alasan;
    final DateTime? dibuatPada;
    final String status_denda;
    final int? dendaId;

    
    // Relations
    final ProfilPengguna? peminjam;
    final ProfilPengguna? petugas;
    

    Peminjaman({
      required this.id,
      required this.peminjamId,
      this.disetujuiOleh,
      required this.tanggalPinjam,
      required this.tanggalJatuhTempo,
      this.tanggalKembali,
      required this.status,
      required this.status_denda,
      this.hariTerlambat = 0,
      this.alasan,
      this.dendaId,
      this.dibuatPada,
      this.peminjam,
      this.petugas,
    });

    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'peminjam_id': peminjamId,
        'disetujui_oleh': disetujuiOleh,
        'tanggal_pinjam': tanggalPinjam.toIso8601String(),
        'tanggal_jatuh_tempo': tanggalJatuhTempo.toIso8601String(),
        'tanggal_kembali': tanggalKembali?.toIso8601String(),
        'status': status,
        'hari_terlambat': hariTerlambat,
        'alasan': alasan,
        'status_denda':status_denda,
        'dibuat_pada': dibuatPada?.toIso8601String(),
        'denda_id': dendaId,
      };
    }

    factory Peminjaman.fromJson(Map<String, dynamic> json) {
      return Peminjaman(
        id: int.parse(json['id'].toString()),
        peminjamId: json['peminjam_id'] ?? '',
        disetujuiOleh: json['disetujui_oleh'],
        tanggalPinjam: DateTime.parse(json['tanggal_pinjam']),
        tanggalJatuhTempo: DateTime.parse(json['tanggal_jatuh_tempo']),
        tanggalKembali: json['tanggal_kembali'] != null
            ? DateTime.parse(json['tanggal_kembali'])
            : null,
        status: json['status'] ?? 'tunggu_pinjam',
        hariTerlambat: int.parse(json['hari_terlambat'].toString()),
        alasan: json['alasan'],
        dibuatPada: json['dibuat_pada'] != null
            ? DateTime.parse(json['dibuat_pada'])
            : null,
        peminjam: json['peminjam'] != null
            ? ProfilPengguna.fromJson(json['peminjam'])
            : null,
        petugas: json['petugas'] != null
            ? ProfilPengguna.fromJson(json['petugas'])
            : null,
        status_denda:json['status_denda'],
      );
    }


    AppPengajuan toAppPengajuan() {
      return AppPengajuan(
        id: this.id,
        peminjamId: this.peminjamId,
        disetujuiOleh: this.disetujuiOleh,
        tanggalPinjam: this.tanggalPinjam,
        tanggalJatuhTempo: this.tanggalJatuhTempo,
        tanggalKembali: this.tanggalKembali,
        status: this.status,
        hariTerlambat: this.hariTerlambat,
        alasan: this.alasan,
        dibuatPada: this.dibuatPada,
      );
    }
  }