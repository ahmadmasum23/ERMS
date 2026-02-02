import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/modules/borrower/controllers/borrower_controller.dart';

class AjukanKategori extends GetView<BorrowerController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return DropdownButtonFormField<int>(
          value: null,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            labelText: 'Nama kategori',
            labelStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          items: const [],
          onChanged: null,
        );
      }

      return DropdownButtonFormField<int>(
        key: UniqueKey(), // Use a new unique key for this dropdown
        value: controller.slctKategoriId.value,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          labelText: 'Nama kategori *',
          labelStyle: TextStyle(color: Colors.grey),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
        items: [
          const DropdownMenuItem(
            value: null,
            child: Text('Pilih kategori'),
          ),
          ...controller.kategoriList.map(
            (kategori) => DropdownMenuItem(
              value: kategori.id,
              child: Text(kategori.nama),
            ),
          ),
        ],
        onChanged: (value) {
          controller.slctKategoriId.value = value;
          // Reset the item selection when category changes
          controller.slctItemId.clear();
        },
      );
    });
  }
}