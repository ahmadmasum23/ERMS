import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/data/models/AppPengajuan.dart';
import 'package:inven/app/global/utils/Formatter.dart';
import 'package:inven/app/global/widgets/CustomBtnForm.dart';
import 'package:inven/app/global/widgets/CustomShowDialog.dart';
import 'package:inven/app/modules/borrower/controllers/borrower_controller.dart';
import 'package:inven/app/modules/borrower/views/pengembalian/return_panel.dart';

class PengembalianData extends GetView<BorrowerController> {
  final int idItem;
  final bool expand;
  final VoidCallback bttn;
  final AppPengajuan model;

  const PengembalianData({
    required this.idItem,
    required this.expand,
    required this.model,
    required this.bttn,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Add comprehensive null safety
    final nama_barang = model.unit?.first.barang?.nmBarang ?? 'Barang tidak tersedia';
    final merk_barang = model.unit?.first.barang?.merk ?? 'Merk tidak tersedia';
    final kode_barang = model.unit?.first.barang?.kdBarang ?? 'Kode tidak tersedia';
    final peminjam = model.pengguna?.nama ?? 'Peminjam tidak tersedia';
    final status = model.status?.pStatus ?? 'Status tidak tersedia';
    final jumlah = model.jumlah.toString();
    final hal = model.hal ?? 'Keperluan tidak diisi';
    final tanggal = Formatter.dateID(model.kembaliTgl);

    //text style
    final title = const TextStyle(fontSize: 13, color: Colors.black);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //nama barang
                Text(
                  nama_barang,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),

                //merk barang
                Text('Merk: ${merk_barang}'),
              ],
            ),

            //badge kode barang
            Container(
              margin: const EdgeInsets.all(0),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(kode_barang, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),

        const SizedBox(height: 10),

        //nama peminjam barang
        Row(
          children: [
            const SizedBox(width: 5),
            Icon(Icons.person, size: 15),
            Text(' $peminjam •', style: title),
          ],
        ),

        const SizedBox(height: 5),

        //status peminjaman
        Row(
          children: [
            const SizedBox(width: 5),
            Icon(Icons.shopping_cart, size: 15),
            Text(' $status', style: title),
          ],
        ),

        const SizedBox(height: 5),

        //tanggal pengembalian
        Row(
          children: [
            const SizedBox(width: 5),
            Icon(Icons.watch_later, size: 15),
            Text(' $tanggal', style: title),
          ],
        ),

        const SizedBox(height: 5),

        //jumlah unit dipinjam
        Row(
          children: [
            const SizedBox(width: 5),
            Icon(Icons.archive, size: 15),
            Text(' $jumlah unit', style: title),
          ],
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            //keperluan peminjaman
            Expanded(
              child: TextField(
                controller: TextEditingController(text: hal),
                readOnly: true,
                enabled: false,
                maxLines: null,
                style: TextStyle(color: Colors.black, fontSize: 12),
                decoration: InputDecoration(
                  label: Text('Keperluan'),
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  isDense: true,
                  disabledBorder: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 5),

            //button expand
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(5),
              ),
              child: IconButton(
                onPressed: bttn,
                icon: Icon(
                  expand ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        //button pengembalian
        CustomBtnForm(
          label: 'kembalikan',
          isLoading: controller.isBtnLoad.value,
          OnPress: () {
            final barang = model.unit?.first.barang;
            if (barang != null) {
              Get.dialog(
                CustomShowDialog(
                  widthFactor: 0.50,
                  heightFactor: 0.20,
                  rounded: 30,
                  child: ReturnPanel(model: model),
                ),
              );
            } else {
              return;
            }
          },
        ),
      ],
    );
  }
}