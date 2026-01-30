import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';
import 'package:inven/app/data/models/AppKategori.dart';
import '../../controllers/admin_kategori_controller.dart';

class AdminKategoriManagementView extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final AdminKategoriController controller = Get.put(AdminKategoriController());

  AdminKategoriManagementView({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppbar(
          title: 'Kategori Management',
          boldTitle: 'Panel',
          showNotif: false,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtitle
                Text(
                  'Kelola kategori alat',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 20),

                // Tambah Kategori Button
                Align(
                  alignment: Alignment.topRight,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddKategoriDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah Kategori'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Judul Section
                Text(
                  'Daftar Kategori',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Daftar Kategori
                _buildCategoryList(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.kategoriList.isEmpty) {
        return const Center(
          child: Text(
            'Belum ada kategori',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      double screenWidth = MediaQuery.of(context).size.width;
      int columns = screenWidth > 600 ? 3 : 2;
      double itemWidth = (screenWidth - 48 - (columns - 1) * 16) / columns;

      List<Widget> cards = controller.kategoriList.map((kategori) {
        int itemCount = controller.getAlatCount(kategori.id);
        return _buildCategoryCard(
          context: context,
          kategori: kategori,
          itemCount: itemCount,
        );
      }).toList();

      List<Widget> rows = [];
      for (int i = 0; i < cards.length; i += columns) {
        List<Widget> rowItems = [];
        for (int j = 0; j < columns && (i + j) < cards.length; j++) {
          rowItems.add(
            SizedBox(
              width: itemWidth,
              child: cards[i + j],
            ),
          );
          if (j < columns - 1 && (i + j + 1) < cards.length) {
            rowItems.add(const SizedBox(width: 16));
          }
        }
        rows.add(Row(children: rowItems));
        if (i + columns < cards.length) {
          rows.add(const SizedBox(height: 16));
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      );
    });
  }

  Widget _buildCategoryCard({
  required BuildContext context,
  required AppKategori kategori,
  required int itemCount,
}) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade200),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF4F7F7),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul + Edit Icon
          Row(
            children: [
              Expanded(
                child: Text(
                  kategori.nama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _showEditKategoriDialog(context, kategori),
                icon: const Icon(
                  Icons.edit,
                  size: 18,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Kode: ${kategori.kode}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // Jumlah Alat + Hapus Icon — RESPONSIF
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Jumlah Alat',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$itemCount',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _confirmDeleteKategori(context, kategori),
                icon: const Icon(
                  Icons.delete,
                  size: 18,
                  color: Colors.redAccent,
                ),
                tooltip: 'Hapus kategori',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  void _showAddKategoriDialog(BuildContext context) {
    final kodeController = TextEditingController();
    final namaController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kategori Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: kodeController,
              decoration: const InputDecoration(
                labelText: 'Kode Kategori',
                hintText: 'Contoh: MESIN',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                hintText: 'Contoh: Mesin Jahit',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (kodeController.text.isNotEmpty && namaController.text.isNotEmpty) {
                Navigator.pop(context);
                await controller.addKategori(
                  kode: kodeController.text.trim(),
                  nama: namaController.text.trim(),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditKategoriDialog(BuildContext context, AppKategori kategori) {
    final kodeController = TextEditingController(text: kategori.kode);
    final namaController = TextEditingController(text: kategori.nama);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Kategori'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: kodeController,
              decoration: const InputDecoration(
                labelText: 'Kode Kategori',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (kodeController.text.isNotEmpty && namaController.text.isNotEmpty) {
                Navigator.pop(context);
                await controller.updateKategori(
                  id: kategori.id,
                  kode: kodeController.text.trim(),
                  nama: namaController.text.trim(),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteKategori(BuildContext context, AppKategori kategori) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus kategori "${kategori.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await controller.deleteKategori(kategori.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}