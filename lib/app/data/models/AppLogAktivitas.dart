import 'package:flutter/material.dart';

class AppLogAktivitas {
  final int id;
  final String? penggunaId;
  final String aksi;
  final String entitas;
  final int? entitasId;
  final Map<String, dynamic>? nilaiLama;
  final Map<String, dynamic>? nilaiBaru;
  final DateTime dibuatPada;
  final String? namaPengguna; // From join with profil_pengguna
  final String? peranPengguna; // From join with profil_pengguna

  AppLogAktivitas({
    required this.id,
    this.penggunaId,
    required this.aksi,
    required this.entitas,
    this.entitasId,
    this.nilaiLama,
    this.nilaiBaru,
    required this.dibuatPada,
    this.namaPengguna,
    this.peranPengguna,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pengguna_id': penggunaId,
      'aksi': aksi,
      'entitas': entitas,
      'entitas_id': entitasId,
      'nilai_lama': nilaiLama,
      'nilai_baru': nilaiBaru,
      'dibuat_pada': dibuatPada.toIso8601String(),
    };
  }

  factory AppLogAktivitas.fromJson(Map<String, dynamic> json) {
    // Handle the joined profil_pengguna data that might be flattened
    return AppLogAktivitas(
      id: json['id'] as int,
      penggunaId: json['pengguna_id']?.toString(),
      aksi: json['aksi']?.toString() ?? '',
      entitas: json['entitas']?.toString() ?? '',
      entitasId: json['entitas_id'] as int?,
      nilaiLama: json['nilai_lama'] as Map<String, dynamic>?,
      nilaiBaru: json['nilai_baru'] as Map<String, dynamic>?,
      dibuatPada: DateTime.parse(json['dibuat_pada'].toString()),
      namaPengguna: json['nama_lengkap']?.toString() ?? json['profil_pengguna']?['nama_lengkap']?.toString(),
      peranPengguna: json['peran']?.toString() ?? json['profil_pengguna']?['peran']?.toString(),
    );
  }

  // Helper methods for UI display
  String getActionDisplay() {
    switch (aksi.toLowerCase()) {
      case 'created':
      case 'create':
        return 'Created';
      case 'updated':
      case 'update':
        return 'Updated';
      case 'deleted':
      case 'delete':
        return 'Deleted';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'submitted':
        return 'Submitted';
      case 'confirmed_return':
      case 'confirmed return':
        return 'Confirmed Return';
      default:
        return aksi;
    }
  }

  Color getActionColor() {
    switch (aksi.toLowerCase()) {
      case 'created':
      case 'create':
      case 'approved':
        return Colors.green.withOpacity(0.1);
      case 'updated':
      case 'update':
        return Colors.blue.withOpacity(0.1);
      case 'deleted':
      case 'delete':
        return Colors.red.withOpacity(0.1);
      case 'rejected':
        return Colors.orange.withOpacity(0.1);
      case 'submitted':
        return Colors.amber.withOpacity(0.1);
      case 'confirmed_return':
      case 'confirmed return':
        return Colors.purple.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  Color getActionTextColor() {
    switch (aksi.toLowerCase()) {
      case 'created':
      case 'create':
      case 'approved':
        return Colors.green;
      case 'updated':
      case 'update':
        return Colors.blue;
      case 'deleted':
      case 'delete':
        return Colors.red;
      case 'rejected':
        return Colors.orange;
      case 'submitted':
        return Colors.amber;
      case 'confirmed_return':
      case 'confirmed return':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String getAvatarLetter() {
    if (namaPengguna != null && namaPengguna!.isNotEmpty) {
      return namaPengguna!.substring(0, 1).toUpperCase();
    }
    return '?';
  }

  String getUserDisplay() {
    if (namaPengguna != null && peranPengguna != null) {
      return '$namaPengguna ($peranPengguna)';
    } else if (namaPengguna != null) {
      return namaPengguna!;
    } else if (penggunaId != null) {
      return 'User ID: ${penggunaId}';
    }
    return 'Unknown User';
  }

  String getTimeDisplay() {
    final now = DateTime.now();
    final difference = now.difference(dibuatPada);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dibuatPada.day}/${dibuatPada.month}/${dibuatPada.year}';
    }
  }
}