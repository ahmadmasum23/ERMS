import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/data/models/AturanDenda.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';
import '../../controllers/aturan_denda_controller.dart';

class AturanDendaViews extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final AturanDendaController controller = Get.put(AturanDendaController());

  AturanDendaViews({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppbar(
          title: 'Denda Management',
          boldTitle: 'Panel',
          showNotif: false,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kelola aturan denda keterlambatan & kerusakan',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 20),

                /// Tombol Tambah
                Align(
                  alignment: Alignment.topRight,
                  child: ElevatedButton.icon(
                    onPressed: () => _showFormDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah Aturan'),
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

                Text(
                  'Daftar Aturan Denda',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                _buildList(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ================= LIST =================
  Widget _buildList(BuildContext context) {
    return Obx(() {
      if (controller.listAturan.isEmpty) {
        return const Center(
          child: Text(
            'Belum ada aturan denda',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      double screenWidth = MediaQuery.of(context).size.width;
      int columns = screenWidth > 600 ? 3 : 2;
      double itemWidth = (screenWidth - 48 - (columns - 1) * 16) / columns;

      List<Widget> cards = controller.listAturan.map((aturan) {
        return _buildCard(context, aturan);
      }).toList();

      List<Widget> rows = [];
      for (int i = 0; i < cards.length; i += columns) {
        List<Widget> rowItems = [];
        for (int j = 0; j < columns && (i + j) < cards.length; j++) {
          rowItems.add(SizedBox(width: itemWidth, child: cards[i + j]));
          if (j < columns - 1 && (i + j + 1) < cards.length) {
            rowItems.add(const SizedBox(width: 16));
          }
        }
        rows.add(Row(children: rowItems));
        if (i + columns < cards.length) rows.add(const SizedBox(height: 16));
      }

      return Column(children: rows);
    });
  }

  /// ================= CARD =================
  Widget _buildCard(BuildContext context, AturanDenda aturan) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    aturan.jenis.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.black54),
                  onPressed: () => _showFormDialog(context, aturan: aturan),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              aturan.keterangan ?? '-',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Rp ${aturan.jumlah}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.delete,
                      size: 18, color: Colors.redAccent),
                  onPressed: () => _confirmDelete(context, aturan),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ================= DIALOG FORM =================
  void _showFormDialog(BuildContext context, {AturanDenda? aturan}) {
    final isEdit = aturan != null;

    if (isEdit) controller.isiFormDariData(aturan);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Aturan' : 'Tambah Aturan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.jenisController.value.isEmpty
                      ? null
                      : controller.jenisController.value,
                  items: controller.jenisOptions
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => controller.jenisController.value = v ?? '',
                  decoration: const InputDecoration(labelText: 'Jenis'),
                )),
            const SizedBox(height: 12),
            TextField(
              controller: controller.jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.keteranganController,
              decoration: const InputDecoration(labelText: 'Keterangan'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (isEdit) {
                controller.updateAturan(aturan.id);
              } else {
                controller.tambahAturan();
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AturanDenda aturan) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Hapus aturan ${aturan.jenis}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              controller.hapusAturan(aturan.id);
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
