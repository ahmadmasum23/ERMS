import 'AppKategori.dart';

class AppAlat {
  final int id;
  final String nama;
  final int? kategoriId;
  final String kondisi; // 'baik', 'rusak_ringan', 'rusak_berat'
  final String? urlGambar;
  final DateTime? dibuatPada;
  final int stok;
  final String? kodeAlat;
  final String status; // 'tersedia', 'dipinjam', 'tidak_layak'
  
  // Relation
  final AppKategori? kategori;

  AppAlat({
    required this.id,
    required this.nama,
    this.kategoriId,
    required this.kondisi,
    this.urlGambar,
    this.dibuatPada,
    required this.stok,
    this.kodeAlat,
    this.status = 'tersedia',
    this.kategori,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'kategori_id': kategoriId,
      'kondisi': kondisi,
      'url_gambar': urlGambar,
      'dibuat_pada': dibuatPada?.toIso8601String(),
      'stok': stok,
      'kode_alat': kodeAlat,
      'status': status,
    };
  }

  factory AppAlat.fromJson(Map<String, dynamic> json) {
    return AppAlat(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nama: json['nama'] ?? '',
      kategoriId: json['kategori_id'] is int 
          ? json['kategori_id'] 
          : int.tryParse(json['kategori_id'].toString()),
      kondisi: json['kondisi'] ?? 'baik',
      urlGambar: json['url_gambar'],
      dibuatPada: json['dibuat_pada'] != null
          ? DateTime.parse(json['dibuat_pada'])
          : null,
      stok: int.tryParse(json['stok'].toString()) ?? 1,
      kodeAlat: json['kode_alat'],
      status: json['status'] ?? 'tersedia',
      kategori: json['kategori'] != null
          ? AppKategori.fromJson(json['kategori'])
          : null,
    );
  }
}