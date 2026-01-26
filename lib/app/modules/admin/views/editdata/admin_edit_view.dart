import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:inven/app/data/models/AppBarang.dart';
import 'package:inven/app/modules/admin/controllers/admin_edit_controller.dart';
import 'package:inven/app/modules/admin/views/editdata/edit_panel_footer.dart';
import 'package:inven/app/modules/admin/views/editdata/edit_panel_form.dart';
import 'package:inven/app/modules/admin/views/editdata/edit_panel_header.dart';

class AdminEditView extends GetView<AdminEditController> {
  final AppBarang model;

  AdminEditView({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller with the model data
    controller.setModel(model);
    
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditPanelHeader(model: model),

          const SizedBox(height: 10),

          Expanded(child: EditPanelForm()),

          const SizedBox(height: 15),

          EditPanelFooter(model: model),
        ],
      ),
    );
  }
}
