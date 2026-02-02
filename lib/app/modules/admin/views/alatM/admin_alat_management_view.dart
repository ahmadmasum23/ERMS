import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';
import 'package:inven/app/global/widgets/CustomTxtForm.dart';
import 'package:get/get.dart';
import 'package:inven/app/modules/admin/controllers/admin_alat_controller.dart';
import 'package:inven/app/modules/admin/views/alatM/body_alatM_new.dart';
import 'package:image_picker/image_picker.dart';

class AdminAlatManagementView extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final AdminAlatController controller = Get.put(AdminAlatController());

  AdminAlatManagementView({Key? key, required this.scaffoldKey})
    : super(key: key);

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
                backgroundColor: Colors.black,
                onPressed: () => _showAddAlatDialog(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.white),
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
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
    final kodeAlatController = TextEditingController();

    dynamic selectedImage; // Ganti dari File? ke dynamic
    final ImagePicker picker = ImagePicker();

    String selectedKondisi = 'baik';
    String selectedStatus = 'tersedia';
    int selectedKategoriId = 0;

    Widget _buildImageWidget(dynamic file) {
      if (kIsWeb) {
        if (file is XFile) {
          return FutureBuilder<Uint8List>(
            future: file.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return InteractiveViewer(
                  // biar bisa zoom dikit kalau mau
                  child: Image.memory(
                    snapshot.data!,
                    fit: BoxFit.contain, // 🔥 INI KUNCINYA
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        }
      } else {
        if (file is XFile) {
          return FutureBuilder<Uint8List>(
            future: file.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return InteractiveViewer(
                  child: Image.memory(
                    snapshot.data!,
                    fit: BoxFit.contain, // 🔥 INI JUGA
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        }
      }

      return const Center(child: Text("Gagal load gambar"));
    }

    Future<void> pickImage(
      ImageSource source,
      StateSetter setStateDialog,
    ) async {
      print('DEBUG: Picking image from source: $source');
      print('DEBUG: Platform is web: $kIsWeb');

      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (image != null) {
        print('DEBUG: Image picked successfully: ${image.name}');
        setStateDialog(() {
          selectedImage =
              image; // Sekarang ini akan XFile baik di web maupun mobile
        });
      } else {
        print('DEBUG: No image selected');
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
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
                    controller: kodeAlatController,
                    decoration: const InputDecoration(
                      labelText: 'Kode Alat (opsional)',
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),

                  /// ===== FOTO ALAT =====
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Foto Alat"),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () =>
                            pickImage(ImageSource.gallery, setStateDialog),
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: selectedImage == null
                              ? const Center(
                                  child: Text(
                                    "Tap untuk pilih gambar dari galeri",
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _buildImageWidget(selectedImage!),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

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
                    onChanged: (value) => selectedKondisi = value!,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'tersedia',
                        child: Text('Tersedia'),
                      ),
                      DropdownMenuItem(
                        value: 'dipinjam',
                        child: Text('Dipinjam'),
                      ),
                      DropdownMenuItem(
                        value: 'tidak_layak',
                        child: Text('Tidak Layak'),
                      ),
                    ],
                    onChanged: (value) => selectedStatus = value!,
                  ),
                  const SizedBox(height: 16),

                  Obx(() {
                    return DropdownButtonFormField<int>(
                      value: selectedKategoriId == 0
                          ? null
                          : selectedKategoriId,
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
                          (k) => DropdownMenuItem(
                            value: k.id,
                            child: Text('${k.kode} - ${k.nama}'),
                          ),
                        ),
                      ],
                      onChanged: (value) => selectedKategoriId = value ?? 0,
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
                  Get.snackbar("Error", "Nama alat harus diisi");
                  return;
                }

                final stokValue = int.tryParse(stokController.text);
                if (stokValue == null || stokValue <= 0) {
                  Get.snackbar("Error", "Stok harus angka positif");
                  return;
                }

                Navigator.pop(context);

                await controller.addAlat(
                  nama: namaController.text.trim(),
                  kategoriId: selectedKategoriId == 0
                      ? null
                      : selectedKategoriId,
                  kondisi: selectedKondisi,
                  stok: stokValue,
                  kodeAlat: kodeAlatController.text.trim().isEmpty
                      ? null
                      : kodeAlatController.text.trim(),
                  status: selectedStatus,
                  imageFile: selectedImage, // ⬅ kirim file, bukan URL
                );
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }
}
