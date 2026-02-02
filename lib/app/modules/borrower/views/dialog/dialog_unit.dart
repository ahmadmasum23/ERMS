import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/modules/borrower/controllers/borrower_controller.dart';

class DialogUnit extends GetView<BorrowerController> {
  const DialogUnit({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Icon(Icons.category, color: Colors.grey.shade700, size: 16),
          const SizedBox(width: 8),
          Text(
            'Kategori: ',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          if (controller.slctKategoriId.value != null)
            Text(
              controller.kategoriList
                  .firstWhereOrNull((k) => k.id == controller.slctKategoriId.value)
                  ?.nama ??
                  'Tidak ditemukan',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            )
          else
            Text(
              'Belum dipilih',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }
}
