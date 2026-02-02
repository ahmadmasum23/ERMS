import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Tambahkan import ini
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

    // Format date dengan intl package
    String tanggalText = 'Belum ada tanggal';
    if (dibuatPada != null) {
      tanggalText = DateFormat('dd/MM/yyyy HH:mm').format(dibuatPada);
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Container(
        // === CONTAINER LUAR: PUTIH DENGAN BORDER ===
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[200]!,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Container(
          // === CONTAINER DALAM: BACKGROUND LEMBUT ===
          decoration: BoxDecoration(
            color: const Color(0xffF9FAFB), // Warna lembut seperti contoh
            borderRadius: BorderRadius.circular(
              7,
            ), // Sedikit lebih kecil dari luar
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
                    top: Radius.circular(7),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(7),
                  ),
                  child: _buildMediumImageWidget(urlGambar),
                ),
              ),

              // Product Information Section (dengan padding disesuaikan)
              Padding(
                padding: const EdgeInsets.all(14),
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
                    const SizedBox(height: 10),

                    // Kode Alat Badge
                    if (kodeAlat != 'N/A') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[300]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.qr_code_2,
                              size: 16,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Kode: $kodeAlat',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Product Details Row
                    _buildCompactProductDetailsRow(
                      kodeKategori,
                      kategori,
                      kondisiText,
                      stok,
                    ),

                    const SizedBox(height: 14),

                    // Info Row: Tanggal Dibuat + Status
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Dibuat',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tanggalText,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: statusColor.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
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
                                      'Status',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Admin Actions
                    _buildCompactAdminActions(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... (method-method lainnya tetap sama: _buildCompactProductDetailsRow, _buildCompactAdminActions, dll)
  // Saya tidak tulis ulang semua method untuk efisiensi, hanya struktur wrapper yang berubah

  Widget _buildCompactProductDetailsRow(
    String kodeKategori,
    String kategori,
    String kondisiText,
    int stok,
  ) {
    Color kondisiColor = _getKondisiColor(model.kondisi);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildInfoBox('Kode', kodeKategori, Colors.grey),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: _buildInfoBox('Kategori', kategori, Colors.grey),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: _buildInfoBox('Kondisi', kondisiText, kondisiColor),
        ),
        const SizedBox(width: 10),
        Expanded(flex: 2, child: _buildInfoBox('Stok', '$stok', Colors.orange)),
      ],
    );
  }

  Widget _buildInfoBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
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
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
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
          child: SingleChildScrollView(
            // Tambahkan ini agar dialog scrollable
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
                // Status Dropdown
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
                  'Peringatan',
                  'Nama alat tidak boleh kosong',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              if (int.tryParse(stokController.text) == null ||
                  int.parse(stokController.text) <= 0) {
                Get.snackbar(
                  'Peringatan',
                  'Stok harus angka positif',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              Navigator.pop(context);
              await controller.updateAlat(
                id: alat.id,
                nama: namaController.text.trim(),
                stok: int.parse(stokController.text),
                urlGambar: urlGambarController.text.trim().isEmpty
                    ? null
                    : urlGambarController.text.trim(),
                kondisi: selectedKondisi,
                status: selectedStatus,
                kodeAlat: kodeAlatController.text.trim().isEmpty
                    ? null
                    : kodeAlatController.text.trim(),
                kategoriId: selectedKategoriId == 0 ? null : selectedKategoriId,
              );
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
