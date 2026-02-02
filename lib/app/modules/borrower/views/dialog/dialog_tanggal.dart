import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/global/utils/Formatter.dart';
import 'package:inven/app/modules/borrower/controllers/borrower_controller.dart';

class DialogTanggal extends GetView<BorrowerController> {
  const DialogTanggal({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3),
                  child: Icon(
                    Icons.insert_invitation_sharp,
                    color: Colors.grey.shade50,
                    size: 15,
                  ),
                ),

                const SizedBox(width: 5),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dipinjam:',
                      style: TextStyle(
                        color: Colors.grey.shade50,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      controller.tglPinjam.value != null
                          ? Formatter.dateID(controller.tglPinjam.toString())
                          : 'Belum dipilih',
                      style: TextStyle(
                        color: controller.tglPinjam.value != null
                            ? Colors.grey.shade50
                            : Colors.grey.shade300,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3),
                  child: Icon(
                    Icons.watch_later_outlined,
                    color: Colors.grey.shade50,
                    size: 15,
                  ),
                ),

                const SizedBox(width: 5),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dikembalikan:',
                      style: TextStyle(
                        color: Colors.grey.shade50,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      controller.tglKembali.value != null
                          ? Formatter.dateID(controller.tglKembali.toString())
                          : 'Belum dipilih',
                      style: TextStyle(
                        color: controller.tglKembali.value != null
                            ? Colors.grey.shade50
                            : Colors.grey.shade300,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
