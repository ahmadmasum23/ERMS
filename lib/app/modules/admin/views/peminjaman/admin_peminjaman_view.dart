import 'package:flutter/material.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';

class AdminPeminjamanView extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AdminPeminjamanView({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppbar(
          title: 'Peminjaman',
          boldTitle: 'Panel',
          showNotif: false,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        Expanded(
          child: Center(child: Text('Dashboard Admin - Siap dikembangkan')),
        ),
      ],
    );
  }
}
