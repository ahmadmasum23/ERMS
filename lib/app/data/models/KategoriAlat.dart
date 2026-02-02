class KategoriAlat {
  final int id;
  final String kode;
  final String nama;
  final DateTime? dibuatPada;

  KategoriAlat({
    required this.id,
    required this.kode,
    required this.nama,
    this.dibuatPada,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode': kode,
      'nama': nama,
      'dibuat_pada': dibuatPada?.toIso8601String(),
    };
  }

  factory KategoriAlat.fromJson(Map<String, dynamic> json) {
    return KategoriAlat(
      id: int.parse(json['id'].toString()),
      kode: json['kode'] ?? '',
      nama: json['nama'] ?? '',
      dibuatPada: json['dibuat_pada'] != null
          ? DateTime.parse(json['dibuat_pada'])
          : null,
    );
  }
}