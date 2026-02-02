import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/modules/borrower/controllers/borrower_controller.dart';

class AjukanBarang extends GetView<BorrowerController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return DropdownButtonFormField<int>(
          value: null,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            labelText: 'Nama barang',
            labelStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          items: const [],
          onChanged: null,
        );
      }

      return DropdownButtonFormField<int?> (
        key: controller.dropitem,
        value: controller.selectedItemId.value,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          labelText: 'Nama alat *',
          labelStyle: TextStyle(color: Colors.grey),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.refresh, size: 18),
            onPressed: () {
              print('DEBUG: Refresh button pressed');
              controller.manualRefresh();
            },
          ),
        ),
        items: [
          const DropdownMenuItem(
            value: null,
            child: Text('Pilih alat'),
          ),
          ...controller.itemList.where((item) {
            // Filter items by selected category if a category is selected
            if (controller.slctKategoriId.value != null) {
              return item.kategoriId == controller.slctKategoriId.value;
            }
            // If no category is selected, show all items
            return true;
          }).map(
            (item) => DropdownMenuItem(
              value: item.id,
              child: Text(item.nama),
            ),
          ),
        ],
        onChanged: (value) {
          controller.selectedItemId.value = value;
          // Reset unit selection when item changes
          controller.slctUnitId.clear();
          controller.isCheckAll.value = false;
        },
      );
    });
  }
}