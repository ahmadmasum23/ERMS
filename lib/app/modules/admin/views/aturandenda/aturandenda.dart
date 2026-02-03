import 'package:flutter/material.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';
import 'package:inven/app/modules/admin/controllers/admin_controller.dart';

class AturanDendaViews extends StatelessWidget {
  final dynamic scaffoldKey;

  const AturanDendaViews({Key? key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        CustomAppbar(
          title: 'Admin',
          boldTitle: 'Atur Denda',
          showNotif: false,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
        ),
      ],
    );
  }
}