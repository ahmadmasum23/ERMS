import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/data/models/AppAlat.dart';
import 'package:inven/app/global/controllers/global_user_controller.dart';
import 'package:inven/app/modules/admin/controllers/admin_alat_controller.dart';

class DataAlatNew extends StatelessWidget {
  final AppAlat model;

  const DataAlatNew({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final nama = model.nama;
    final kategori = model.kategori?.nama ?? 'Tidak ada kategori';
    final kodeKategori = model.kategori?.kode ?? 'N/A';
    final kondisi = model.kondisi;
    final stok = model.stok;
    final urlGambar = model.urlGambar;
    final dibuatPada = model.dibuatPada;
    final kodeAlat = model.kodeAlat ?? 'N/A';
    final status = model.status;

    // Format kondisi text
    String kondisiText = kondisi;
    if (kondisi == 'baik') kondisiText = 'Baik';
    if (kondisi == 'rusak_ringan') kondisiText = 'Rusak Ringan';
    if (kondisi == 'rusak_berat') kondisiText = 'Rusak Berat';

    // Format status text
    String statusText = status;
    Color statusColor = Colors.grey;
    if (status == 'tersedia') {
      statusText = 'Tersedia';
      statusColor = Colors.green;
    } else if (status == 'dipinjam') {
      statusText = 'Dipinjam';
      statusColor = Colors.orange;
    } else if (status == 'tidak_layak') {
      statusText = 'Tidak Layak';
      statusColor = Colors.red;
    }

    // Format date
    String tanggalText = 'Belum ada tanggal';
    if (dibuatPada != null) {
      tanggalText = '${dibuatPada.day}/${dibuatPada.month}/${dibuatPada.year}';
    }

    // Debug information
    print('=== ALAT DEBUG INFO ===');
    print('ID: ${model.id}');
    print('Nama: $nama');
    print('Kode Kategori: $kodeKategori');
    print('Kategori Name: $kategori');
    print('Kondisi: $kondisi');
    print('Stok: $stok');
    print('URL Gambar: $urlGambar');
    print('Tanggal Dibuat: $tanggalText');
    print('Kode Alat: $kodeAlat');
    print('Status: $status');
    print('====================');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Header with Medium Image
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: _buildMediumImageWidget(urlGambar),
            ),
          ),

          // Product Information Section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Product Details Row
                _buildCompactProductDetailsRow(
                  kodeKategori,
                  kategori,
                  kondisiText,
                  stok,
                ),

                const SizedBox(height: 12),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        status == 'tersedia' 
                          ? Icons.check_circle
                          : status == 'dipinjam' 
                            ? Icons.access_time
                            : Icons.cancel,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Admin Actions
                _buildCompactAdminActions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactProductDetailsRow(
    String kodeKategori,
    String kategori,
    String kondisiText,
    int stok,
  ) {
    Color kondisiColor = _getKondisiColor(model.kondisi);

    return Row(
      children: [
        // Kode Kategori
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kode',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  kodeKategori,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Kategori
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kategori',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  kategori,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Kondisi
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kondisiColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: kondisiColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Kondisi',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  kondisiText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: kondisiColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Stok
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Stok',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$stok',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactAdminActions(BuildContext context) {
    // Debug: Cek status controller
    print(
      'DEBUG: GlobalUserController registered? ${Get.isRegistered<GlobalUserController>()}',
    );

    if (!Get.isRegistered<GlobalUserController>()) {
      // Untuk debugging: tampilkan placeholder sementara
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          '[Controller belum siap]',
          style: TextStyle(color: Colors.grey[500], fontSize: 10),
        ),
      );
    }

    return Obx(() {
      final userController = Get.find<GlobalUserController>();
      final currentUser = userController.user.value;

      // Debug: Cek status user
      print('DEBUG: currentUser = $currentUser');
      if (currentUser != null) {
        print('DEBUG: currentUser.peranId = ${currentUser.peranId}');
      }

      if (currentUser == null) {
        // Untuk debugging: tampilkan placeholder saat belum login
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '[Belum login]',
            style: TextStyle(color: Colors.blue[500], fontSize: 10),
          ),
        );
      }

      if (currentUser.peranId != 1) {
        // Untuk debugging: tampilkan role user
        final roleText = currentUser.peranId == 2
            ? 'Operator'
            : currentUser.peranId == 3
            ? 'Peminjam'
            : 'User';
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '[Role: $roleText - Hanya admin yang bisa edit/hapus]',
            style: TextStyle(color: Colors.orange[700], fontSize: 10),
          ),
        );
      }

      // Hanya tampilkan tombol untuk admin (peranId == 1)
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _showEditDialog(context, model);
              },
              icon: const Icon(Icons.edit, size: 14),
              label: const Text('Edit', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _confirmDelete(context, model);
              },
              icon: const Icon(Icons.delete, size: 14),
              label: const Text('Hapus', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMediumImageWidget(String? urlGambar) {
    if (urlGambar == null || urlGambar.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 30, color: Colors.grey),
            SizedBox(height: 4),
            Text(
              'No Image',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      );
    }

    print('DEBUG: Loading medium image from URL: $urlGambar');

    // Check for blocked domains
    final blockedDomains = [
      'pinimg.com',
      'pinterest.com',
      'instagram.com',
      'facebook.com',
    ];
    final isBlockedDomain = blockedDomains.any(
      (domain) => urlGambar.contains(domain),
    );

    if (isBlockedDomain) {
      print('DEBUG: Blocked domain detected: $urlGambar');
      return _buildMediumErrorWidget(urlGambar, 'CORS Blocked', true);
    }

    if (!_isValidUrl(urlGambar)) {
      return _buildMediumErrorWidget(urlGambar, 'URL Invalid', false);
    }

    return Image.network(
      urlGambar.trim(),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('DEBUG: Medium image failed to load. Error: $error');

        String errorMessage = 'Failed';
        if (error.toString().contains('statusCode: 0')) {
          errorMessage = 'CORS';
        } else if (error.toString().contains('SocketException')) {
          errorMessage = 'Network';
        } else if (error.toString().contains('404')) {
          errorMessage = 'Not Found';
        }

        return _buildMediumErrorWidget(
          urlGambar,
          errorMessage,
          errorMessage == 'CORS',
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          print('DEBUG: Medium image loaded successfully');
          return child;
        }
        return Container(
          color: Colors.grey[100],
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          ),
        );
      },
      cacheWidth: 200,
      cacheHeight: 120,
      filterQuality: FilterQuality.medium,
      headers: const {'Accept': 'image/*'},
    );
  }

  Widget _buildMediumErrorWidget(String url, String error, bool isCorsError) {
    return Container(
      color: isCorsError ? Colors.orange[50] : Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCorsError ? Icons.block : Icons.broken_image,
            size: 25,
            color: isCorsError ? Colors.orange : Colors.red,
          ),
          Text(
            error,
            style: TextStyle(
              fontSize: 10,
              color: isCorsError ? Colors.orange[800] : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  Color _getKondisiColor(String kondisi) {
    switch (kondisi) {
      case 'baik':
        return Colors.green;
      case 'rusak_ringan':
        return Colors.orange;
      case 'rusak_berat':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showEditDialog(BuildContext context, AppAlat alat) {
    final namaController = TextEditingController(text: alat.nama);
    final stokController = TextEditingController(text: alat.stok.toString());
    final urlGambarController = TextEditingController(
      text: alat.urlGambar ?? '',
    );
    final kodeAlatController = TextEditingController(text: alat.kodeAlat ?? '');
    String selectedKondisi = alat.kondisi;
    String selectedStatus = alat.status;
    int selectedKategoriId = alat.kategoriId ?? 0;

    final controller = Get.find<AdminAlatController>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Alat'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Alat',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: stokController,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlGambarController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Kode Alat field
              TextField(
                controller: kodeAlatController,
                decoration: const InputDecoration(
                  labelText: 'Kode Alat (opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Kondisi Dropdown
              DropdownButtonFormField<String>(
                value: selectedKondisi,
                decoration: const InputDecoration(
                  labelText: 'Kondisi',
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
              // Status Dropdown
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'tersedia', child: Text('Tersedia')),
                  DropdownMenuItem(value: 'dipinjam', child: Text('Dipinjam')),
                  DropdownMenuItem(value: 'tidak_layak', child: Text('Tidak Layak')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedStatus = value;
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
                        child: Text(kategori.nama),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (namaController.text.isNotEmpty) {
                Navigator.pop(context);
                await controller.updateAlat(
                  id: alat.id,
                  nama: namaController.text.trim(),
                  stok: int.tryParse(stokController.text) ?? alat.stok,
                  urlGambar: urlGambarController.text.trim().isEmpty
                      ? null
                      : urlGambarController.text.trim(),
                  kondisi: selectedKondisi,
                  status: selectedStatus,
                  kodeAlat: kodeAlatController.text.trim().isEmpty
                      ? null
                      : kodeAlatController.text.trim(),
                  kategoriId: selectedKategoriId == 0
                      ? null
                      : selectedKategoriId,
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppAlat alat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus alat "${alat.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final controller = Get.find<AdminAlatController>();
              await controller.deleteAlat(alat.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
