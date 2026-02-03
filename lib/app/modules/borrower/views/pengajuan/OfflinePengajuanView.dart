// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:inven/app/data/services/peminjaman_service.dart';
// import 'package:inven/app/data/services/alat_service.dart';
// import 'package:inven/app/modules/borrower/controllers/borrower_controller.dart';

// class OfflinePengajuanView extends GetView<BorrowerController> {
//   const OfflinePengajuanView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Pengajuan Offline'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.sync),
//             onPressed: () {
//               controller.syncOfflinePengajuan();
//             },
//             tooltip: 'Sinkronkan pengajuan offline',
//           ),
//         ],
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: controller.getLocalPengajuan(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.error, size: 48, color: Colors.red.shade300),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Error memuat data',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.red.shade700,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           final pengajuanList = snapshot.data ?? [];

//           if (pengajuanList.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Tidak ada pengajuan offline',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Semua pengajuan Anda berhasil dikirim',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade500,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: pengajuanList.length,
//             itemBuilder: (context, index) {
//               final pengajuan = pengajuanList[index];
              
//               return Card(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Header
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.orange.shade100,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               'PENDING',
//                               style: TextStyle(
//                                 color: Colors.orange.shade800,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             _formatDate(pengajuan['createdAt']),
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
                      
//                       const SizedBox(height: 12),
                      
//                       // Peminjam
//                       _buildInfoRow(
//                         Icons.person,
//                         'Peminjam',
//                         pengajuan['peminjamName'],
//                       ),
                      
//                       const SizedBox(height: 8),
                      
//                       // Kategori
//                       _buildInfoRow(
//                         Icons.category,
//                         'Kategori',
//                         pengajuan['categoryName'] ?? 'Tidak ditemukan',
//                       ),
                      
//                       const SizedBox(height: 8),
                      
//                       // Alat yang dipilih
//                       _buildEquipmentList(pengajuan['equipmentNames']),
                      
//                       const SizedBox(height: 8),
                      
//                       // Tanggal
//                       Row(
//                         children: [
//                           Icon(Icons.calendar_today, 
//                               size: 16, 
//                               color: Colors.grey.shade600),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Tanggal Pinjam:',
//                                   style: TextStyle(
//                                     color: Colors.grey.shade600,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                                 Text(
//                                   _formatDate(pengajuan['borrowDate']),
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Tanggal Kembali:',
//                                   style: TextStyle(
//                                     color: Colors.grey.shade600,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                                 Text(
//                                   _formatDate(pengajuan['returnDate']),
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
                      
//                       const SizedBox(height: 8),
                      
//                       // Keperluan
//                       if (pengajuan['reason'] != null && pengajuan['reason'].toString().isNotEmpty)
//                         _buildInfoRow(
//                           Icons.notes,
//                           'Keperluan',
//                           pengajuan['reason'],
//                         ),
                      
//                       const SizedBox(height: 16),
                      
//                       // Action button
//                       Row(
//                         children: [
//                           Expanded(
//                             child: OutlinedButton.icon(
//                               onPressed: () {
//                                 _deletePengajuan(pengajuan);
//                               },
//                               icon: const Icon(Icons.delete, size: 16),
//                               label: const Text('Hapus'),
//                               style: OutlinedButton.styleFrom(
//                                 foregroundColor: Colors.red,
//                                 side: BorderSide(color: Colors.red.shade300),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: ElevatedButton.icon(
//                               onPressed: () {
//                                 _retryPengajuan(pengajuan);
//                               },
//                               icon: const Icon(Icons.refresh, size: 16),
//                               label: const Text('Coba Lagi'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blue,
//                                 foregroundColor: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Row(
//       children: [
//         Icon(icon, size: 16, color: Colors.grey.shade600),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: Colors.grey.shade600,
//                   fontSize: 12,
//                 ),
//               ),
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEquipmentList(List<dynamic> equipmentNames) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(Icons.inventory, size: 16, color: Colors.grey.shade600),
//             const SizedBox(width: 8),
//             Text(
//               'Alat (${equipmentNames.length})',
//               style: TextStyle(
//                 color: Colors.grey.shade600,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         ...equipmentNames.map((name) {
//           return Container(
//             margin: const EdgeInsets.only(bottom: 4),
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.check, size: 12, color: Colors.blue.shade700),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     name.toString(),
//                     style: TextStyle(
//                       color: Colors.blue.shade800,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }

//   String _formatDate(String dateString) {
//     try {
//       final date = DateTime.parse(dateString);
//       return '${date.day}/${date.month}/${date.year}';
//     } catch (e) {
//       return dateString;
//     }
//   }

//   void _deletePengajuan(Map<String, dynamic> pengajuanData) {
//     Get.defaultDialog(
//       title: 'Hapus Pengajuan',
//       middleText: 'Apakah Anda yakin ingin menghapus pengajuan offline ini?',
//       textConfirm: 'Hapus',
//       textCancel: 'Batal',
//       confirmTextColor: Colors.white,
//       buttonColor: Colors.red,
//       onConfirm: () async {
//         Get.back();
//         // Hapus pengajuan dari storage
//         await controller.deleteLocalPengajuanByData(pengajuanData);
        
//         Get.snackbar(
//           'Dihapus',
//           'Pengajuan berhasil dihapus',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
        
//         // Refresh halaman
//         Get.back(); // Tutup dialog
//         Get.to(() => const OfflinePengajuanView()); // Refresh halaman
//       },
//     );
//   }

//   void _retryPengajuan(Map<String, dynamic> pengajuan) {
//     Get.defaultDialog(
//       title: 'Coba Kirim Ulang',
//       middleText: 'Apakah Anda ingin mencoba mengirimkan pengajuan ini kembali?',
//       textConfirm: 'Kirim',
//       textCancel: 'Batal',
//       confirmTextColor: Colors.white,
//       buttonColor: Colors.blue,
//       onConfirm: () async {
//         Get.back();
//         try {
//           // Coba kirim pengajuan kembali
//           final user = Get.find<BorrowerController>().userCtrl.user.value;
          
//           if (user != null) {
//             final peminjamanService = PeminjamanService();
            
//             // Buat pengajuan baru ke server
//             final peminjaman = await peminjamanService.createPeminjaman(
//               peminjamId: pengajuan['userId'],
//               tanggalPinjam: DateTime.parse(pengajuan['borrowDate']),
//               tanggalJatuhTempo: DateTime.parse(pengajuan['returnDate']),
//               status: 'menunggu',
//               alasan: pengajuan['reason'],
//             );

//             // Buat detail peminjaman untuk setiap alat
//             final List<int> equipmentIds = List<int>.from(pengajuan['equipmentIds']);
//             final alatService = AlatService();
            
//             for (int equipmentId in equipmentIds) {
//               await peminjamanService.createDetailPeminjaman(
//                 peminjamanId: peminjaman.id,
//                 alatId: equipmentId,
//                 kondisiSaatPinjam: 'baik', // Gunakan kondisi default
//               );
              
//               // Update status alat
//               await alatService.updateAlat(id: equipmentId, status: 'dipinjam');
//             }

//             // Hapus dari offline storage
//             await Get.find<BorrowerController>().deleteLocalPengajuanByData(pengajuan);
            
//             Get.snackbar(
//               'Berhasil',
//               'Pengajuan berhasil dikirim',
//               backgroundColor: Colors.green,
//               colorText: Colors.white,
//             );
            
//             // Refresh halaman
//             Get.find<BorrowerController>().refresh();
//             Get.back(); // Tutup dialog
//             Get.back(); // Refresh halaman
//             Get.to(() => const OfflinePengajuanView());
//           }
//         } catch (e) {
//           Get.snackbar(
//             'Gagal',
//             'Gagal mengirim pengajuan: ${e.toString()}',
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//           );
//         }
//       },
//     );
//   }
// }