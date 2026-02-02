import 'Peminjaman.dart';
import 'AturanDenda.dart';

class Denda {
  final int id;
  final int? peminjamanId;
  final int? aturanDendaId;
  final num jumlah;
  final DateTime? dibuatPada;
  
  // Relations
  final Peminjaman? peminjaman;
  final AturanDenda? aturanDenda;

  Denda({
    required this.id,
    this.peminjamanId,
    this.aturanDendaId,
    required this.jumlah,
    this.dibuatPada,
    this.peminjaman,
    this.aturanDenda,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'peminjaman_id': peminjamanId,
      'aturan_denda_id': aturanDendaId,
      'jumlah': jumlah,
      'dibuat_pada': dibuatPada?.toIso8601String(),
    };
  }

  factory Denda.fromJson(Map<String, dynamic> json) {
    return Denda(
      id: int.parse(json['id'].toString()),
      peminjamanId: json['peminjaman_id'] is int 
          ? json['peminjaman_id'] 
          : int.tryParse(json['peminjaman_id'].toString()),
      aturanDendaId: json['aturan_denda_id'] is int 
          ? json['aturan_denda_id'] 
          : int.tryParse(json['aturan_denda_id'].toString()),
      jumlah: json['jumlah'] is int 
          ? json['jumlah'] 
          : double.parse(json['jumlah'].toString()),
      dibuatPada: json['dibuat_pada'] != null
          ? DateTime.parse(json['dibuat_pada'])
          : null,
      peminjaman: json['peminjaman'] != null
          ? Peminjaman.fromJson(json['peminjaman'])
          : null,
      aturanDenda: json['aturan_denda'] != null
          ? AturanDenda.fromJson(json['aturan_denda'])
          : null,
    );
  }
}