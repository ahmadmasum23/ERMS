import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:inven/app/modules/borrower/views/pengajuan/borrower_ajukan_view.dart';
import 'package:inven/app/modules/borrower/views/pengembalian/borrower_pengembalian_view.dart';
import 'package:inven/app/modules/borrower/views/profile/borrower_profile_view.dart';
import 'package:inven/app/modules/borrower/views/riwayat/borrower_riwayat_view.dart';
import 'package:inven/app/modules/borrower/views/inventaris/borrower_equipment_view.dart';

import '../controllers/borrower_controller.dart';

class BorrowerView extends GetView<BorrowerController> {
  const BorrowerView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: IndexedStack(
          index: controller.isIndex.value,
          children: [
            BorrowerEquipmentView(),

            BorrowerAjukanView(),

            BorrowerRiwayatView(), //masih dummy

            BorrowerPengembalianView(),

            BorrowerProfileView(),
          ],
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.black,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: controller.isIndex.value,
            onTap: controller.onChangePage,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory),
                label: 'Inventaris',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.add_box),
                label: 'Peminjaman barang',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Riwayat',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.view_list),
                label: 'Pengembalian barang',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil pengguna',
              ),
            ],
          ),
        ),
      );
    });
  }
}
