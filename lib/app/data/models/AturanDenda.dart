class AturanDenda {
  final int id;
  final String jenis; // 'terlambat', 'rusak', 'hilang'
  final num jumlah;
  final String? keterangan;

  AturanDenda({
    required this.id,
    required this.jenis,
    required this.jumlah,
    this.keterangan,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jenis': jenis,
      'jumlah': jumlah,
      'keterangan': keterangan,
    };
  }

  factory AturanDenda.fromJson(Map<String, dynamic> json) {
    return AturanDenda(
      id: int.parse(json['id'].toString()),
      jenis: json['jenis'] ?? '',
      jumlah: json['jumlah'] is int 
          ? json['jumlah'] 
          : double.parse(json['jumlah'].toString()),
      keterangan: json['keterangan'],
    );
  }
}