import 'package:flutter/material.dart';
import 'package:inven/app/global/widgets/CustomAppBar.dart';
import 'package:inven/app/global/widgets/CustomTxtForm.dart';
import 'package:get/get.dart';
import 'package:inven/app/modules/admin/controllers/admin_alat_controller.dart';

import 'package:inven/app/modules/admin/views/alatM/body_alatM_new.dart';

class AdminAlatManagementView extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final AdminAlatController controller = Get.put(AdminAlatController());

  AdminAlatManagementView({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppbar(
          title: 'Alat Management',
          boldTitle: 'Panel',
          showNotif: false,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CustomTxtForm(
            Label: 'Cari alat',
            Controller: controller.searchController,
            Focus: FocusNode(),
            OnSubmit: (val) {
              controller.onSearchChanged(val!);
            },
            OnChange: (val) {
              controller.onSearchChanged(val!);
            },
          ),
        ),

        const SizedBox(height: 15),

        // Category filter chips and refresh button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category filter chips
              Expanded(
                child: Obx(() {
                  return Wrap(
                    spacing: 8,
                    children: [
                      // "Semua" filter
                      FilterChip(
                        label: const Text('Semua', style: TextStyle(color: Colors.white, fontSize: 12)),
                        selected: controller.selectedKategoriFilter.value == 0,
                        selectedColor: Colors.black,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.black, width: 1),
                        ),
                        onSelected: (selected) {
                          controller.onKategoriFilterChanged(selected ? 0 : controller.selectedKategoriFilter.value);
                        },
                      ),
                      // Category filters
                      ...controller.kategoriOptions.map((kategori) => 
                        FilterChip(
                          label: Text(kategori.nama, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          selected: controller.selectedKategoriFilter.value == kategori.id,
                          selectedColor: Colors.black,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Colors.black, width: 1),
                          ),
                          onSelected: (selected) {
                            controller.onKategoriFilterChanged(selected ? kategori.id : 0);
                          },
                        )
                      ).toList(),
                    ],
                  );
                }),
              ),
              
              // Refresh button
              IconButton(
                onPressed: () {
                  controller.fetchAlat();
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // List of Alat
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.separated(
                padding: const EdgeInsets.all(0),
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.filteredAlatList.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 8);
                },
                itemBuilder: (context, index) {
                  final item = controller.filteredAlatList[index];

                  return BodyAlatMNew(model: item);
                },
              );
            }),
          ),
        ),
      
      ],
    );
  }
}