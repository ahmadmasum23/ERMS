// admin_view.dart (diperbarui)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/modules/admin/views/activity/admin_activity_log_view.dart';
import 'package:inven/app/modules/admin/views/admin_drawer.dart';
import 'package:inven/app/modules/admin/views/alatM/admin_alat_management_view.dart';
import 'package:inven/app/modules/admin/views/dashboard/admin_dashboard_view.dart';
import 'package:inven/app/modules/admin/views/kategoriM/admin_kategori_management_view.dart';
import 'package:inven/app/modules/admin/views/peminjaman/admin_peminjaman_view.dart';
import 'package:inven/app/modules/admin/views/pengembalian/admin_pengembalian_view.dart';
import 'package:inven/app/modules/admin/views/userM/admin_user_management_view.dart';
import 'package:inven/app/modules/admin/views/profile/admin_profile_view.dart';
import '../controllers/admin_controller.dart';

class AdminView extends GetView<AdminController> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        key: _scaffoldKey,
        drawer: AdminDrawer(controller: controller),
        body: IndexedStack(
          index: controller.isIndex.value,
          children: [
            AdminDashboardView(scaffoldKey: _scaffoldKey),
            AdminUserManagementView(scaffoldKey: _scaffoldKey),
            AdminAlatManagementView(scaffoldKey: _scaffoldKey),
            AdminKategoriManagementView(scaffoldKey: _scaffoldKey),
            AdminPeminjamanView(scaffoldKey: _scaffoldKey),
            AdminPengembalianView(scaffoldKey: _scaffoldKey),
            AdminActivityLogView(scaffoldKey: _scaffoldKey),
            AdminProfileView(scaffoldKey: _scaffoldKey),
          ],
        ),
      );
    });
  }
}