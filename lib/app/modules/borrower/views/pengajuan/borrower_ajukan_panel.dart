import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:inven/app/global/widgets/CustomBG.dart';
import 'package:inven/app/modules/borrower/controllers/borrower_controller.dart';
import 'package:inven/app/modules/borrower/views/pengajuan/AjukanKategori.dart';
import 'package:inven/app/modules/borrower/views/pengajuan/AjukanDaftarAlat.dart';
import 'package:inven/app/modules/borrower/views/pengajuan/AjukanKembali.dart';
import 'package:inven/app/modules/borrower/views/pengajuan/AjukanKeperluan.dart';
import 'package:inven/app/modules/borrower/views/pengajuan/AjukanPemohon.dart';
import 'package:inven/app/modules/borrower/views/pengajuan/AjukanPinjam.dart';
import 'package:inven/app/modules/borrower/views/pengajuan/AjukanUnit.dart';

class BorrowerAjukanPanel extends GetView<BorrowerController> {
  const BorrowerAjukanPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final impl = const TextStyle(fontWeight: FontWeight.bold, fontSize: 20);

    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: CustomBackground(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Informasi Peminjam', style: impl),
                  IconButton(
                    onPressed: () {
                      controller.refresh();
                      controller.resetForm();
                    },
                    icon: Icon(Icons.refresh),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: AjukanPemohon()),
                ],
              ),

              const SizedBox(height: 10),

              AjukanKeperluan(),

              const SizedBox(height: 10),
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: AjukanPinjam()),

                  const SizedBox(width: 20),

                  Expanded(child: AjukanKembali()),
                ],
              ),

              const SizedBox(height: 20),

              // Add the new category selection field
              AjukanKategori(),

              const SizedBox(height: 10),

              // Add the equipment list based on selected category
              Text('Daftar Alat', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              AjukanDaftarAlat(),
            ],
          ),
        ),
      ),
    );
  }
}