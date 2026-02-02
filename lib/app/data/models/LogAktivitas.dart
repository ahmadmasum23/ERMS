import 'dart:convert';
import 'package:flutter/material.dart';

class LogAktivitas {
  final int id;
  final String? penggunaId;
  final String aksi; // 'INSERT', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 'APPROVE', 'REJECT', 'RETURN'
  final String entitas;
  final int? entitasId;
  final Map<String, dynamic>? nilaiLama;
  final Map<String, dynamic>? nilaiBaru;
  final DateTime? dibuatPada;
  final String? namaPengguna;
  final String? peranPengguna;
  final List<String>? kolomDiubah;

  LogAktivitas({
    required this.id,
    this.penggunaId,
    required this.aksi,
    required this.entitas,
    this.entitasId,
    this.nilaiLama,
    this.nilaiBaru,
    this.dibuatPada,
    this.namaPengguna,
    this.peranPengguna,
    this.kolomDiubah,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pengguna_id': penggunaId,
      'aksi': aksi,
      'entitas': entitas,
      'entitas_id': entitasId,
      'nilai_lama': nilaiLama != null ? jsonEncode(nilaiLama) : null,
      'nilai_baru': nilaiBaru != null ? jsonEncode(nilaiBaru) : null,
      'dibuat_pada': dibuatPada?.toIso8601String(),
      'nama_pengguna': namaPengguna,
      'peran_pengguna': peranPengguna,
      'kolom_diubah': kolomDiubah,
    };
  }

  factory LogAktivitas.fromJson(Map<String, dynamic> json) {
    return LogAktivitas(
      id: int.parse(json['id'].toString()),
      penggunaId: json['pengguna_id'],
      aksi: json['aksi'] ?? '',
      entitas: json['entitas'] ?? '',
      entitasId: json['entitas_id'] is int 
          ? json['entitas_id'] 
          : int.tryParse(json['entitas_id'].toString()),
      nilaiLama: json['nilai_lama'] != null
          ? (json['nilai_lama'] is String 
              ? jsonDecode(json['nilai_lama']) as Map<String, dynamic>
              : json['nilai_lama'] as Map<String, dynamic>?)
          : null,
      nilaiBaru: json['nilai_baru'] != null
          ? (json['nilai_baru'] is String 
              ? jsonDecode(json['nilai_baru']) as Map<String, dynamic>
              : json['nilai_baru'] as Map<String, dynamic>?)
          : null,
      dibuatPada: json['dibuat_pada'] != null
          ? DateTime.parse(json['dibuat_pada'])
          : null,
      namaPengguna: json['nama_pengguna'],
      peranPengguna: json['peran_pengguna'],
      kolomDiubah: json['kolom_diubah'] != null
          ? List<String>.from(json['kolom_diubah'])
          : null,
    );
  }

  // Helper methods for UI display
  String getActionDisplay() {
    switch (aksi.toLowerCase()) {
      case 'insert':
      case 'create':
        return 'Created';
      case 'update':
        return 'Updated';
      case 'delete':
        return 'Deleted';
      case 'approve':
      case 'approved':
        return 'Approved';
      case 'reject':
      case 'rejected':
        return 'Rejected';
      case 'login':
        return 'Login';
      case 'logout':
        return 'Logout';
      case 'return':
      case 'returned':
        return 'Returned';
      default:
        return aksi;
    }
  }

  Color getActionColor() {
    switch (aksi.toLowerCase()) {
      case 'insert':
      case 'create':
      case 'approve':
      case 'approved':
        return Colors.green.withOpacity(0.1);
      case 'update':
        return Colors.blue.withOpacity(0.1);
      case 'delete':
        return Colors.red.withOpacity(0.1);
      case 'reject':
      case 'rejected':
        return Colors.orange.withOpacity(0.1);
      case 'login':
        return Colors.purple.withOpacity(0.1);
      case 'logout':
        return Colors.grey.withOpacity(0.1);
      case 'return':
      case 'returned':
        return Colors.teal.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  Color getActionTextColor() {
    switch (aksi.toLowerCase()) {
      case 'insert':
      case 'create':
      case 'approve':
      case 'approved':
        return Colors.green;
      case 'update':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      case 'reject':
      case 'rejected':
        return Colors.orange;
      case 'login':
        return Colors.purple;
      case 'logout':
        return Colors.grey;
      case 'return':
      case 'returned':
        return Colors.teal;
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
    if (namaPengguna != null && namaPengguna!.isNotEmpty) {
      return namaPengguna!;
    }
    return 'Unknown User';
  }

  String getTimeDisplay() {
    if (dibuatPada == null) {
      return 'Unknown time';
    }
    
    final now = DateTime.now();
    final difference = now.difference(dibuatPada!);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      // Format as date
      return '${dibuatPada!.day}/${dibuatPada!.month}/${dibuatPada!.year}';
    }
  }

}