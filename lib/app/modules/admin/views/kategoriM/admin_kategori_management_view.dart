import 'package:flutter/material.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';

class AdminKategoriManagementView extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AdminKategoriManagementView({Key? key, required this.scaffoldKey}) : super(key: key);

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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur Tambah Kategori belum diimplementasi')),
                      );
                    },
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
    double screenWidth = MediaQuery.of(context).size.width;
    int columns = screenWidth > 600 ? 3 : 2;
    double itemWidth = (screenWidth - 48 - (columns - 1) * 16) / columns;

    List<Widget> cards = [
      _buildCategoryCard(
        context: context,
        title: 'Elektronik',
        description: 'Peralatan elektronik seperti laptop, proyektor, dll',
        itemCount: 15,
      ),
      _buildCategoryCard(
        context: context,
        title: 'Olahraga',
        description: 'Peralatan olahraga seperti bola, net, dll',
        itemCount: 20,
      ),
      _buildCategoryCard(
        context: context,
        title: 'Multimedia',
        description: 'Peralatan multimedia seperti kamera, mic, dll',
        itemCount: 10,
      ),
      _buildCategoryCard(
        context: context,
        title: 'Kelistrikan',
        description: 'Alat-alat kelistrikan dan perbaikan',
        itemCount: 12,
      ),
    ];

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
  }

  Widget _buildCategoryCard({
  required BuildContext context,
  required String title,
  required String description,
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
                  title,
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Edit $title')),
                  );
                },
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
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 2,
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hapus $title')),
                  );
                },
                icon: const Icon(
                  Icons.delete,
                  size: 18,
                  color: Colors.redAccent,
                ),
                // Tambahkan tooltip untuk aksesibilitas
                tooltip: 'Hapus kategori',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}