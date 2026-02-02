import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/data/models/Alat.dart';
import 'package:inven/app/data/services/alat_service.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';
import 'package:inven/app/global/widgets/CustomFilterChips.dart';
import 'package:inven/app/global/widgets/CustomTxtForm.dart';

class BorrowerEquipmentView extends StatefulWidget {
  const BorrowerEquipmentView({super.key});

  @override
  State<BorrowerEquipmentView> createState() => _BorrowerEquipmentViewState();
}

class _BorrowerEquipmentViewState extends State<BorrowerEquipmentView> {
  final AlatService _alatService = AlatService();
  final TextEditingController _searchController = TextEditingController();

  var equipments = <Alat>[].obs;
  var filteredEquipments = <Alat>[].obs;
  var isLoading = false.obs;
  var selectedCategoryIndex = 0.obs; // Use int index instead of String

  @override
  void initState() {
    super.initState();
    _fetchEquipment();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEquipment() async {
    try {
      isLoading.value = true;
      final data = await _alatService.getAllAlat();
      equipments.assignAll(data);
      _applyFilters();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal memuat data alat",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      print("ERROR FETCH EQUIPMENT: $e");
    } finally {
      isLoading.value = false;
    }
  }

  List<String> _getUniqueCategories() {
    final categories = equipments
        .map((alat) => alat.kategori?.nama)
        .where((name) => name != null)
        .cast<String>() // Cast to String to avoid null issues
        .toSet()
        .toList();
    categories.sort();
    return ['semua', ...categories];
  }

  void _applyFilters() {
    List<Alat> filtered = List.from(equipments);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (alat) =>
                alat.nama.toLowerCase().contains(searchTerm) ||
                (alat.kategori?.nama.toLowerCase().contains(searchTerm) ??
                    false),
          )
          .toList();
    }

    // Apply category filter
    final categories = _getUniqueCategories();
    if (selectedCategoryIndex.value > 0 &&
        selectedCategoryIndex.value < categories.length) {
      final selectedCategoryName = categories[selectedCategoryIndex.value];
      filtered = filtered
          .where((alat) => alat.kategori?.nama == selectedCategoryName)
          .toList();
    }

    filteredEquipments.assignAll(filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppbar(title: 'Daftar', boldTitle: 'Peralatan', showNotif: false),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CustomTxtForm(
            Label: 'Cari peralatan...',
            Controller: _searchController,
            Focus: FocusNode(),
            OnSubmit: (val) => _applyFilters(),
            OnChange: (val) => _applyFilters(),
          ),
        ),

        const SizedBox(height: 15),

        // Category Filter
        Obx(() {
          final categories = _getUniqueCategories();
          final categoryMap = Map<int, String>.fromIterables(
            List<int>.generate(categories.length, (i) => i),
            categories,
          );

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomFilterChips(
                    opsi: categoryMap,
                    select: selectedCategoryIndex.value,
                    isSelect: (val) {
                      selectedCategoryIndex.value = val;
                      _applyFilters();
                    },
                  ),
                ),
                IconButton(
                  onPressed: _fetchEquipment,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh data',
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 15),

        // Equipment List
        Expanded(
          child: Obx(() {
            if (isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (filteredEquipments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada peralatan ditemukan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Coba ubah kata kunci pencarian atau filter',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: filteredEquipments.length,
              itemBuilder: (context, index) {
                final equipment = filteredEquipments[index];
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ), // jarak antar card
                  child: _buildEquipmentCard(equipment),
                );
              },
            );
          }),
        ),
      ],
    );
  }
  Widget _buildEquipmentCard(Alat equipment) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 6,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GAMBAR DI KIRI (mobile-friendly size)
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (equipment.urlGambar != null && equipment.urlGambar!.isNotEmpty)
                  ? Image.network(
                      equipment.urlGambar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: Icon(Icons.image_not_supported, color: Colors.grey, size: 32),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image, color: Colors.grey, size: 32),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // KONTEN KANAN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NAMA & KATEGORI
                Text(
                  equipment.nama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                if (equipment.kategori != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      equipment.kategori!.nama,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // INFO DETAIL GRID 2 KOLOM (mobile-optimized)
                _buildInfoGrid(equipment),

                const SizedBox(height: 12),

                // STATUS + TOMBOL (sejajar di mobile)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: equipment.stok > 0
                            ? Colors.green.withOpacity(0.12)
                            : Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            equipment.stok > 0 ? Icons.check_circle : Icons.cancel,
                            size: 14,
                            color: equipment.stok > 0 ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            equipment.stok > 0 ? 'Tersedia' : 'Habis',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: equipment.stok > 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (equipment.stok > 0)
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.snackbar(
                            'Info',
                            'Silakan ajukan peminjaman melalui menu Pengajuan',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        icon: const Icon(Icons.shopping_bag, size: 16),
                        label: const Text('Ajukan', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// GRID 2 KOLOM KHUSUS MOBILE
Widget _buildInfoGrid(Alat equipment) {
  return Column(
    children: [
      // Baris 1: Kode + Kategori
      Row(
        children: [
          Expanded(child: _buildInfoBox('Kode', equipment.kodeAlat ?? 'N/A', Colors.grey)),
          const SizedBox(width: 10),
          Expanded(child: _buildInfoBox('Kategori', equipment.kategori?.nama ?? 'N/A', Colors.blue)),
        ],
      ),
      const SizedBox(height: 10),
      // Baris 2: Kondisi + Stok
      Row(
        children: [
          Expanded(
            child: _buildInfoBox(
              'Kondisi',
              _formatKondisi(equipment.kondisi),
              equipment.kondisi == 'baik'
                  ? Colors.green
                  : (equipment.kondisi == 'rusak_ringan' ? Colors.orange : Colors.red),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildInfoBox(
              'Stok',
              '${equipment.stok}',
              equipment.stok > 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    ],
  );
}

// WIDGET INFO BOX MOBILE (compact tapi jelas)
Widget _buildInfoBox(String label, String value, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.25), width: 0.8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

// Helper format kondisi
String _formatKondisi(String kondisi) {
  switch (kondisi) {
    case 'baik':
      return 'Baik';
    case 'rusak_ringan':
      return 'Rsk Ringan';
    case 'rusak_berat':
      return 'Rsk Berat';
    default:
      return kondisi;
  }
}
}
