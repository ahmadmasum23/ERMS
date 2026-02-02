  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'dart:typed_data';
  import 'package:flutter/foundation.dart';
  import 'package:intl/intl.dart';
  import 'package:inven/app/data/models/Alat.dart';
  import 'package:inven/app/global/controllers/global_user_controller.dart';
  import 'package:inven/app/modules/admin/controllers/admin_alat_controller.dart';
  import 'package:image_picker/image_picker.dart';
  import 'dart:io';

  class DataAlatNew extends StatelessWidget {
    final Alat model;

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
        tanggalText = DateFormat('dd/MM/yyyy HH:mm').format(dibuatPada);
      }

      // === STRUKTUR CARD DENGAN GAMBAR DI SAMPING KIRI ===
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffF4F7F7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === GAMBAR DI SAMPING KIRI (FIXED WIDTH 90x90) ===
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade200, width: 0.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: _buildNaturalImageWidget(urlGambar),
                  ),
                ),
                const SizedBox(width: 14),

                // === KONTEN TEKS DI SEBELAH KANAN ===
                Expanded(
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
                      const SizedBox(height: 6),

                      // Kode Alat Badge
                      if (kodeAlat != 'N/A') ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.blue[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.qr_code_2, size: 14, color: Colors.blue[700]),
                              const SizedBox(width: 4),
                              Text(
                                'Kode: $kodeAlat',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Product Details Row
                      _buildCompactProductDetailsRow(
                        kodeKategori,
                        kategori,
                        kondisiText,
                        stok,
                      ),
                      const SizedBox(height: 10),

                      // Info Row: Tanggal + Status
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dibuat',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tanggalText,
                                    style: const TextStyle(
                                      fontSize: 10,
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
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: statusColor.withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 10,
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
                      const SizedBox(height: 10),

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

    // Widget untuk menampilkan gambar dengan proporsi alami
    Widget _buildNaturalImageWidget(String? urlGambar) {
      if (urlGambar == null || urlGambar.isEmpty) {
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.image, size: 24, color: Colors.grey),
          ),
        );
      }

      // Validasi blocked domains
      final blockedDomains = [
        'pinimg.com',
        'pinterest.com',
        'instagram.com',
        'facebook.com',
      ];
      final isBlockedDomain = blockedDomains.any((domain) => urlGambar.contains(domain));
      
      if (isBlockedDomain) {
        return Container(
          color: Colors.orange[50],
          child: const Center(
            child: Icon(Icons.block, size: 24, color: Colors.orange),
          ),
        );
      }

      if (!_isValidUrl(urlGambar)) {
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.broken_image, size: 24, color: Colors.grey),
          ),
        );
      }

      return Container(
        color: Colors.grey[50],
        child: Center(
          child: Image.network(
            urlGambar.trim(),
            fit: BoxFit.contain, // TAMPILKAN SELURUH GAMBAR TANPA DISTORSI
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              String errorMessage = 'Failed';
              if (error.toString().contains('statusCode: 0')) {
                errorMessage = 'CORS';
              } else if (error.toString().contains('SocketException')) {
                errorMessage = 'Network';
              } else if (error.toString().contains('404')) {
                errorMessage = 'Not Found';
              }

              return Container(
                color: errorMessage == 'CORS' ? Colors.orange[50] : Colors.grey[100],
                child: Center(
                  child: Icon(
                    errorMessage == 'CORS' ? Icons.block : Icons.broken_image,
                    size: 24,
                    color: errorMessage == 'CORS' ? Colors.orange : Colors.grey,
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[50],
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                ),
              );
            },
            cacheWidth: 200,
            cacheHeight: 200,
            filterQuality: FilterQuality.medium,
          ),
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
          Expanded(
            flex: 2,
            child: _buildInfoBox('Kode', kodeKategori, Colors.grey),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: _buildInfoBox('Kategori', kategori, Colors.grey),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _buildInfoBox('Kondisi', kondisiText, kondisiColor),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: _buildInfoBox('Stok', '$stok', Colors.orange)),
        ],
      );
    }

    Widget _buildInfoBox(String label, String value, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: TextStyle(
                fontSize: 10,
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
      if (!Get.isRegistered<GlobalUserController>()) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            '[Controller belum siap]',
            style: TextStyle(color: Colors.grey[500], fontSize: 9),
          ),
        );
      }

      return Obx(() {
        final userController = Get.find<GlobalUserController>();
        final currentUser = userController.user.value;

        if (currentUser == null) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '[Belum login]',
              style: TextStyle(color: Colors.blue[500], fontSize: 9),
            ),
          );
        }

        if (!currentUser.isAdmin) {
          final roleText = currentUser.isPetugas
              ? 'Operator'
              : currentUser.isPeminjam
                  ? 'Peminjam'
                  : 'User';
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '[Role: $roleText]',
              style: TextStyle(color: Colors.orange[700], fontSize: 9),
            ),
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showEditDialog(context, model);
                },
                icon: const Icon(Icons.edit, size: 12),
                label: const Text('Edit', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _confirmDelete(context, model);
                },
                icon: const Icon(Icons.delete, size: 12),
                label: const Text('Hapus', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        );
      });
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

    void _showEditDialog(BuildContext context, Alat alat) {
      final namaController = TextEditingController(text: alat.nama);
      final stokController = TextEditingController(text: alat.stok.toString());
      final kodeAlatController = TextEditingController(text: alat.kodeAlat ?? '');

      String selectedKondisi = alat.kondisi;
      String selectedStatus = alat.status;
      int selectedKategoriId = alat.kategoriId ?? 0;

      dynamic selectedImage;
      final ImagePicker picker = ImagePicker();
      final controller = Get.find<AdminAlatController>();

      Future<void> pickImage(StateSetter setStateDialog) async {
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );
        if (image != null) {
          setStateDialog(() => selectedImage = image);
        }
      }

      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: const Text('Edit Alat'),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Foto Alat"),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => pickImage(setStateDialog),
                          child: Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _buildImageWidget(selectedImage!),
                                  )
                                : (alat.urlGambar != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          alat.urlGambar!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Center(child: Text("Tap untuk pilih gambar"))),
                          ),
                        ),
                      ],
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
                    DropdownButtonFormField<String>(
                      value: selectedKondisi,
                      decoration: const InputDecoration(
                        labelText: 'Kondisi *',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'baik', child: Text('Baik')),
                        DropdownMenuItem(value: 'rusak_ringan', child: Text('Rusak Ringan')),
                        DropdownMenuItem(value: 'rusak_berat', child: Text('Rusak Berat')),
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
                        DropdownMenuItem(value: 'tersedia', child: Text('Tersedia')),
                        DropdownMenuItem(value: 'dipinjam', child: Text('Dipinjam')),
                        DropdownMenuItem(value: 'tidak_layak', child: Text('Tidak Layak')),
                      ],
                      onChanged: (value) => selectedStatus = value!,
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      return DropdownButtonFormField<int>(
                        value: selectedKategoriId == 0 ? null : selectedKategoriId,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(value: 0, child: Text('Tidak ada kategori')),
                          ...controller.kategoriOptions.map(
                            (k) => DropdownMenuItem(value: k.id, child: Text(k.nama)),
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
                  Navigator.pop(context);
                  await controller.updateAlat(
                    id: alat.id,
                    nama: namaController.text.trim(),
                    stok: int.parse(stokController.text),
                    kondisi: selectedKondisi,
                    status: selectedStatus,
                    kodeAlat: kodeAlatController.text.trim().isEmpty
                        ? null
                        : kodeAlatController.text.trim(),
                    kategoriId: selectedKategoriId == 0 ? null : selectedKategoriId,
                    imageFile: selectedImage,
                  );
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildImageWidget(dynamic file) {
      if (kIsWeb) {
        if (file is XFile) {
          return FutureBuilder<Uint8List>(
            future: file.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Image.memory(snapshot.data!, fit: BoxFit.contain);
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
                return Image.memory(snapshot.data!, fit: BoxFit.contain);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        }
      }
      return const Center(child: Text("Gagal load gambar"));
    }

    void _confirmDelete(BuildContext context, Alat alat) {
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