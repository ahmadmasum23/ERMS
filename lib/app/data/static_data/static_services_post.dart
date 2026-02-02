import '../models/AppPengajuan.dart';
import '../static_data/static_providers.dart';

class StaticServicesPost {

  // Post pengajuan peminjaman barang
  Future<AppPengajuan?> postPengajuan(
    int id,
    String instansi,
    String hal,
    String tglPinjam,
    String tglKembali,
    List<int> unit,
  ) async {
    await Future.delayed(Duration(milliseconds: 1000)); // Simulate network delay
    
    // In a real app, this would save to storage or database
    // For now, we'll just simulate success
    try {
      final newPengajuan = AppPengajuan(
        id: StaticProviders.getPengajuan().length + 1,
        penggunaId: id,
        statusId: 1, // Pending status
        instansi: instansi,
        hal: hal,
        pinjamTgl: tglPinjam,
        kembaliTgl: tglKembali,
        jumlah: unit.length,
        unit: [], // Would populate with actual units in real implementation
        status: null,
        riwayat: [],
      );
      
      return newPengajuan;
    } catch (e) {
      return null;
    }
  }
}