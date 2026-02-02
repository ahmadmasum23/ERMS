import 'package:flutter/material.dart';
import 'package:inven/app/data/models/Alat.dart';
import 'package:inven/app/modules/admin/views/alatM/data_alat_new.dart';

class BodyAlatMNew extends StatelessWidget {
  final Alat model;

  const BodyAlatMNew({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: DataAlatNew(model: model),
    );
  }
}