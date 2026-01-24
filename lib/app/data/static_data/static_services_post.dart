import '../models/AppPengajuan.dart';
import '../models/AppUser.dart';
import '../static_data/static_providers.dart';

class StaticServicesPost {
  // Post user login
  Future<AppUser?> postUser(String email, String pass) async {
    await Future.delayed(Duration(milliseconds: 800)); // Simulate network delay
    
    final user = StaticProviders.authenticateUser(email, pass);
    
    if (user != null) {
      return user;
    } else {
      return null;
    }
  }

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
        pengguna: StaticProviders.getUsers().firstWhere((u) => u.id == id),
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