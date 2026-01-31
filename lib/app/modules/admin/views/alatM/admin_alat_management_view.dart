import 'package:flutter/material.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';
import 'package:inven/app/global/widgets/CustomTxtForm.dart';
import 'package:get/get.dart';
import 'package:inven/app/modules/admin/controllers/admin_alat_controller.dart';

import 'package:inven/app/modules/admin/views/alatM/body_alatM_new.dart';

class AdminAlatManagementView extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final AdminAlatController controller = Get.put(AdminAlatController());

  AdminAlatManagementView({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppbar(
          title: 'Alat Management',
          boldTitle: 'Panel',
          showNotif: false,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        
        // Search bar and Add button row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: CustomTxtForm(
                  Label: 'Cari alat',
                  Controller: controller.searchController,
                  Focus: FocusNode(),
                  OnSubmit: (val) {
                    controller.onSearchChanged(val!);
                  },
                  OnChange: (val) {
                    controller.onSearchChanged(val!);
                  },
                ),
              ),
              const SizedBox(width: 10),
              // Add Alat Button
              FloatingActionButton.small(
                heroTag: "btn_add_alat",
                onPressed: () => _showAddAlatDialog(context),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // Category filter chips and refresh button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category filter chips
              Expanded(
  child: Obx(() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [

          /// === SEMUA ===
          _buildKategoriChip(
            label: "Semua",
            id: 0,
            selectedId: controller.selectedKategoriFilter.value,
            onTap: controller.onKategoriFilterChanged,
          ),

          /// === DATA DARI KATEGORI ===
          ...controller.kategoriOptions.map((kategori) {
            return _buildKategoriChip(
              label: kategori.nama,
              id: kategori.id,
              selectedId: controller.selectedKategoriFilter.value,
              onTap: controller.onKategoriFilterChanged,
            );
          }).toList(),
        ],
      ),
    );
  }),
),

              
              // Refresh button
              IconButton(
                onPressed: () {
                  controller.fetchAlat();
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // List of Alat
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredAlatList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada data alat',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tekan tombol + untuk menambah alat baru',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showAddAlatDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Alat Pertama'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(0),
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.filteredAlatList.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 8);
                },
                itemBuilder: (context, index) {
                  final item = controller.filteredAlatList[index];

                  return BodyAlatMNew(model: item);
                },
              );
            }),
          ),
        ),
      
      ],
    );
  }

  Widget _buildKategoriChip({
  required String label,
  required int id,
  required int selectedId,
  required Function(int) onTap,
}) {
  bool isActive = id == selectedId;

  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: GestureDetector(
      onTap: () => onTap(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.grey[900] : Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[900],
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    ),
  );
}

  void _showAddAlatDialog(BuildContext context) {
    final namaController = TextEditingController();
    final stokController = TextEditingController(text: '1');
    final urlGambarController = TextEditingController();
    
    String selectedKondisi = 'baik';
    int selectedKategoriId = 0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Alat Baru'),
        content: SizedBox(
          width: 300,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Alat *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: stokController,
                  decoration: const InputDecoration(
                    labelText: 'Stok *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: urlGambarController,
                  decoration: const InputDecoration(
                    labelText: 'URL Gambar (opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Kondisi Dropdown
                DropdownButtonFormField<String>(
                  value: selectedKondisi,
                  decoration: const InputDecoration(
                    labelText: 'Kondisi *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'baik', child: Text('Baik')),
                    DropdownMenuItem(
                      value: 'rusak_ringan',
                      child: Text('Rusak Ringan'),
                    ),
                    DropdownMenuItem(
                      value: 'rusak_berat',
                      child: Text('Rusak Berat'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      selectedKondisi = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Kategori Dropdown
                Obx(() {
                  return DropdownButtonFormField<int>(
                    value: selectedKategoriId == 0 ? null : selectedKategoriId,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 0,
                        child: Text('Tidak ada kategori'),
                      ),
                      ...controller.kategoriOptions.map(
                        (kategori) => DropdownMenuItem(
                          value: kategori.id,
                          child: Text('${kategori.kode} - ${kategori.nama}'),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        selectedKategoriId = value;
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (namaController.text.trim().isEmpty) {
                Get.snackbar(
                  "Error",
                  "Nama alat harus diisi",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.shade50,
                  colorText: Colors.red.shade900,
                );
                return;
              }
              
              Navigator.pop(context);
              await controller.addAlat(
                nama: namaController.text.trim(),
                kategoriId: selectedKategoriId == 0 ? null : selectedKategoriId,
                kondisi: selectedKondisi,
                urlGambar: urlGambarController.text.trim().isEmpty 
                    ? null 
                    : urlGambarController.text.trim(),
                stok: int.tryParse(stokController.text) ?? 1,
              );
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}