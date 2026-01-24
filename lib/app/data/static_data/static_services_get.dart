import '../models/AppBarang.dart';
import '../models/AppJenis.dart';
import '../models/AppKategori.dart';
import '../models/AppPengajuan.dart';
import '../models/AppUnitBarang.dart';
import '../static_data/static_providers.dart';

class StaticServicesGet {
  // Data barang
  Future<List<AppBarang>> dataBarang() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
    return StaticProviders.getBarang();
  }

  // Data jenis barang
  Future<List<AppJenis>> dataJenis() async {
    await Future.delayed(Duration(milliseconds: 300));
    return StaticProviders.getJenis();
  }

  // Data kategori barang
  Future<List<AppKategori>> dataKategori() async {
    await Future.delayed(Duration(milliseconds: 300));
    return StaticProviders.getKategori();
  }

  // Data unit barang => operator
  Future<List<AppUnitBarang>> dataUnit() async {
    await Future.delayed(Duration(milliseconds: 400));
    return StaticProviders.getUnitBarang();
  }

  // Data unit barang => borrower only
  Future<List<AppUnitBarang>> borrowerUnit() async {
    await Future.delayed(Duration(milliseconds: 400));
    return StaticProviders.getUnitBarang();
  }

  // Data pengembalian (data yang dipinjam)
  Future<List<AppPengajuan>> dataPinjam(int id) async {
    await Future.delayed(Duration(milliseconds: 500));
    return StaticProviders.getPengajuanByUserId(id);
  }

  // Riwayat untuk borrower role
  Future<List<AppPengajuan>> dataRiwayat(int id) async {
    await Future.delayed(Duration(milliseconds: 500));
    return StaticProviders.getPengajuanByUserId(id);
  }

  // Riwayat untuk role operator (pengajuan)
  Future<List<AppPengajuan>> indexApp() async {
    await Future.delayed(Duration(milliseconds: 600));
    return StaticProviders.getPengajuan();
  }

  // Riwayat untuk role operator (pengembalian)
  Future<List<AppPengajuan>> returnApp() async {
    await Future.delayed(Duration(milliseconds: 600));
    // Return pengajuan with status indicating returns
    return StaticProviders.getPengajuan()
        .where((p) => p.statusId == 2) // Assuming status 2 is for returns
        .toList();
  }

  // Riwayat untuk role operator (all)
  Future<List<AppPengajuan>> indexAll() async {
    await Future.delayed(Duration(milliseconds: 600));
    return StaticProviders.getPengajuan();
  }
}