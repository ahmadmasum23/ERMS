import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/modules/borrower/controllers/borrower_controller.dart';

class AjukanDaftarAlat extends GetView<BorrowerController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, // Fixed height for the list
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Obx(() {
        print('DEBUG: Building AjukanDaftarAlat. itemList length: ${controller.itemList.length}, selected category: ${controller.slctKategoriId.value}');
        // Filter items by selected category
        final filteredItems = controller.itemList.where((item) {
          if (controller.slctKategoriId.value != null) {
            final matches = item.kategoriId == controller.slctKategoriId.value;
            print('DEBUG: Item ${item.id} (${item.nama}) - kategoriId: ${item.kategoriId}, matches: $matches');
            return matches;
          }
          print('DEBUG: No category selected, returning false for item ${item.id}');
          return false; // Don't show items if no category is selected
        }).toList();
        
        print('DEBUG: Filtered items count: ${filteredItems.length}');

        if (filteredItems.isEmpty) {
          return const Center(
            child: Text(
              'Pilih kategori terlebih dahulu',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          key: ValueKey(controller.slctItemId.length), // Rebuild list when selection changes
          shrinkWrap: true,
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            final isSelected = controller.slctItemId.contains(item.id);
            print('DEBUG: Item ${item.id} (${item.nama}) isSelected: $isSelected, current selection: ${controller.slctItemId}');

            return CheckboxListTile(
              key: ValueKey(item.id), // Add unique key for proper rebuilding
              title: Text(item.nama),
              value: isSelected,
              onChanged: (bool? value) {
                if (value == null) return;
                
                if (value) {
                  controller.slctItemId.add(item.id);
                  print('DEBUG: Added item ${item.id} to selection. Current selection: ${controller.slctItemId}');
                } else {
                  controller.slctItemId.remove(item.id);
                  print('DEBUG: Removed item ${item.id} from selection. Current selection: ${controller.slctItemId}');
                }
                
                controller.slctItemId.refresh();
                controller.updateCheck();
                controller.update();
              },
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
        );
      }),
    );
  }
}