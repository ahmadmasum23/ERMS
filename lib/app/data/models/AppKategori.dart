class AppKategori {
  final int id;
  final String kode;
  final String nama;
  final DateTime? dibuatPada;

  AppKategori({
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

  factory AppKategori.fromJson(Map<String, dynamic> json) {
    return AppKategori(
      id: int.tryParse(json['id'].toString()) ?? 0,
      kode: json['kode'] ?? '',
      nama: json['nama'] ?? '',
      dibuatPada: json['dibuat_pada'] != null
          ? DateTime.parse(json['dibuat_pada'])
          : null,
    );
  }

  // For backward compatibility with existing code
  String get kategori => nama;
}
