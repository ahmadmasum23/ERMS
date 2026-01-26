import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/modules/admin/controllers/admin_edit_controller.dart';

class EditMerkBarang extends GetView<AdminEditController> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Colors.black,
      style: const TextStyle(fontSize: 12),
      controller: controller.ctrlMerk,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        labelText: 'Merk barang',
        labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}
