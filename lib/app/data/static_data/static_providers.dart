import '../models/AppBarang.dart';
import '../models/AppJenis.dart';
import '../models/AppKategori.dart';
import '../models/AppPengajuan.dart';
import '../models/AppUnitBarang.dart';
import '../models/AppUser.dart';
import '../models/AppStatusPengajuan.dart';

class StaticProviders {
  // Static user data
  static List<AppUser> getUsers() {
    return [
      AppUser(
        id: 1,
        peranId: 1,
        inst: 'IT Department',
        nama: 'John Doe',
        email: 'admin@gmail.com',
        pass: '1234567890',
      ),
      AppUser(
        id: 2,
        peranId: 2,
        inst: 'Marketing Department',
        nama: 'Jane Smith',
        email: 'petugas@gmail.com',
        pass: '1234567890',
      ),
      AppUser(
        id: 3,
        peranId: 3,
        inst: 'Finance Department',
        nama: 'Bob Wilson',
        email: 'peminjam@gmail.com',
        pass: '1234567890',
      ),
    ];
  }

  // Static barang data
  static List<AppBarang> getBarang() {
    final jenisList = getJenis();
    final kategoriList = getKategori();
    
    return [
      AppBarang(
        id: 1,
        nmBarang: 'Laptop Dell Inspiron',
        kdBarang: 'LPT001',
        kategoriId: 1,
        jenisId: 1,
        merk: 'Dell',
        spkBarang: 'Intel i5, 8GB RAM, 256GB SSD',
        deskripsi: 'Laptop untuk keperluan kerja',
        pengadaan: '2023-01-15',
        garansi: 24,
        sumBarang: '10',
        vendor: 'Dell Indonesia',
        note: 'Barang dalam kondisi baik',
        kategori: kategoriList.firstWhere((k) => k.id == 1),
        jenis: jenisList.firstWhere((j) => j.id == 1),
        unitBarang: [],
      ),
      AppBarang(
        id: 2,
        nmBarang: 'Monitor LG 24 inch',
        kdBarang: 'MON001',
        kategoriId: 2,
        jenisId: 2,
        merk: 'LG',
        spkBarang: '24 inch, Full HD',
        deskripsi: 'Monitor untuk presentasi',
        pengadaan: '2023-02-20',
        garansi: 12,
        sumBarang: '5',
        vendor: 'LG Electronics',
        note: 'Monitor baru',
        kategori: kategoriList.firstWhere((k) => k.id == 2),
        jenis: jenisList.firstWhere((j) => j.id == 2),
        unitBarang: [],
      ),
    ];
  }

  // Static jenis data
  static List<AppJenis> getJenis() {
    return [
      AppJenis(id: 1, jenis: 'Elektronik'),
      AppJenis(id: 2, jenis: 'Furniture'),
      AppJenis(id: 3, jenis: 'ATK'),
    ];
  }

  // Static kategori data
  static List<AppKategori> getKategori() {
    return [
      AppKategori(id: 1, kategori: 'Komputer'),
      AppKategori(id: 2, kategori: 'Display'),
      AppKategori(id: 3, kategori: 'Alat Tulis'),
    ];
  }

  // Static status pengajuan data
  static List<AppStatusPengajuan> getStatusPengajuan() {
    return [
      AppStatusPengajuan(id: 1, pStatus: 'Pending'),
      AppStatusPengajuan(id: 2, pStatus: 'Approved'),
      AppStatusPengajuan(id: 3, pStatus: 'Rejected'),
      AppStatusPengajuan(id: 4, pStatus: 'Returned'),
    ];
  }

  // Static unit barang data
  static List<AppUnitBarang> getUnitBarang() {
    return [
      AppUnitBarang(
        id: 1,
        kdUnit: 'INV-LPT-001',
        noSeri: 'SN123456',
        foto: null,
        barang: getBarang()[0],
        kepemilikan: null,
        status: null,
        lokasi: null,
        kondisi: null,
        pengajuan: [],
        riwayat: [],
      ),
      AppUnitBarang(
        id: 2,
        kdUnit: 'INV-LPT-002',
        noSeri: 'SN123457',
        foto: null,
        barang: getBarang()[0],
        kepemilikan: null,
        status: null,
        lokasi: null,
        kondisi: null,
        pengajuan: [],
        riwayat: [],
      ),
      AppUnitBarang(
        id: 3,
        kdUnit: 'INV-MON-001',
        noSeri: 'SN789012',
        foto: null,
        barang: getBarang()[1],
        kepemilikan: null,
        status: null,
        lokasi: null,
        kondisi: null,
        pengajuan: [],
        riwayat: [],
      ),
    ];
  }

  // Static pengajuan data
  static List<AppPengajuan> getPengajuan() {
    final statusList = getStatusPengajuan();
    
    return [
      AppPengajuan(
        id: 1,
        penggunaId: 2,
        statusId: 1,
        instansi: 'Departemen IT',
        hal: 'Presentasi Proyek',
        pinjamTgl: DateTime.now().add(Duration(days: 1)).toString(),
        kembaliTgl: DateTime.now().add(Duration(days: 3)).toString(),
        jumlah: 2,
        pengguna: getUsers()[1],
        unit: [getUnitBarang()[0]],
        status: statusList.firstWhere((s) => s.id == 1),
        riwayat: [],
      ),
      AppPengajuan(
        id: 2,
        penggunaId: 3,
        statusId: 2,
        instansi: 'Departemen Marketing',
        hal: 'Workshop Training',
        pinjamTgl: DateTime.now().add(Duration(days: 2)).toString(),
        kembaliTgl: DateTime.now().add(Duration(days: 5)).toString(),
        jumlah: 1,
        pengguna: getUsers()[2],
        unit: [getUnitBarang()[1]],
        status: statusList.firstWhere((s) => s.id == 2),
        riwayat: [],
      ),
    ];
  }

  // Helper method to find user by email and password
  static AppUser? authenticateUser(String email, String password) {
    final users = getUsers();
    try {
      return users.firstWhere(
        (user) => user.email == email && user.pass == password,
      );
    } catch (e) {
      return null;
    }
  }

  // Helper method to get pengajuan by user ID
  static List<AppPengajuan> getPengajuanByUserId(int userId) {
    return getPengajuan()
        .where((pengajuan) => pengajuan.penggunaId == userId)
        .toList();
  }

  // Helper method to get unit barang by status
  static List<AppUnitBarang> getUnitBarangByStatus(int statusId) {
    return getUnitBarang()
        .where((unit) => unit.status?.id == statusId)
        .toList();
  }
}