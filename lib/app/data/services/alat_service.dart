import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import '../models/Alat.dart';
import '../models/KategoriAlat.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class AlatService {
  final SupabaseClient _supabase = AuthService().client;

  // Debug method to check authentication status
  void debugAuthStatus() {
    final user = _supabase.auth.currentUser;
    print('=== AUTH DEBUG ===');
    print('Current user: ${user?.id}');
    print('User email: ${user?.email}');
    print('Is logged in: ${user != null}');
    print('==================');
  }

  Future<List<Alat>> getAllAlat() async {
    try {
      // Debug authentication first
      debugAuthStatus();
      
      print('Attempting to fetch alat data from database...');
      final response = await _supabase
          .from('alat')
          .select('*, kategori:kategori_alat(*)')
          .order('nama');
      
      print('Database query successful, got ${response.length} records');
      print('First few items: ${response.take(3).map((e) => e['nama']).toList()}');
      
      final result = response.map((e) => Alat.fromJson(e)).toList();
      print('Converted to ${result.length} Alat objects');
      return result;
    } catch (e) {
      print("ERROR FETCH ALAT: $e");
      print("Error type: ${e.runtimeType}");
      if (e.toString().contains('Postgrest')) {
        print("Postgrest error detected");
        print("Error message: ${e.toString()}");
      }
      rethrow;
    }
  }

  Future<Alat?> getAlatById(int id) async {
    try {
      final response = await _supabase
          .from('alat')
          .select('*, kategori:kategori_alat(*)')
          .eq('id', id)
          .limit(1);
      
      if (response.isEmpty) return null;
      return Alat.fromJson(response.first);
    } catch (e) {
      print("ERROR FETCH ALAT BY ID: $e");
      return null;
    }
  }

  Future<List<Alat>> getAlatByKategori(int kategoriId) async {
    try {
      final response = await _supabase
          .from('alat')
          .select('*, kategori:kategori_alat(*)')
          .eq('kategori_id', kategoriId)
          .order('nama');
      
      return response.map((e) => Alat.fromJson(e)).toList();
    } catch (e) {
      print("ERROR FETCH ALAT BY KATEGORI: $e");
      rethrow;
    }
  }

  Future<Alat> createAlat({
    required String nama,
    int? kategoriId,
    required String kondisi,
    String? urlGambar,
    int stok = 1,
    String? kodeAlat,
    String status = 'tersedia',
  }) async {
    try {
      debugAuthStatus(); // Tambahkan ini untuk debugging auth
      
      final insertData = {
        'nama': nama,
        'kategori_id': kategoriId,
        'kondisi': kondisi,
        'url_gambar': urlGambar,
        'stok': stok,
        'status': status,
      };
      
      if (kodeAlat != null) {
        insertData['kode_alat'] = kodeAlat;
      }
      
      print('DEBUG: Attempting to insert data: $insertData');
      
      final response = await _supabase
          .from('alat')
          .insert(insertData)
          .select('*, kategori:kategori_alat(*)')
          .limit(1);
      
      print('DEBUG: Insert response length: ${response.length}');
      
      if (response.isEmpty) throw Exception('Failed to create alat - no response');
      print('DEBUG: Response data: ${response.first}');
      return Alat.fromJson(response.first);
    } catch (e) {
      print("ERROR CREATE ALAT: $e");
      print("ERROR TYPE: ${e.runtimeType}");
      if (e is Exception) {
        print("ERROR DETAILS: ${e.toString()}");
      }
      rethrow;
    }
  }

  Future<bool> updateAlat({
    required int id,
    String? nama,
    int? kategoriId,
    String? kondisi,
    String? urlGambar,
    int? stok,
    String? kodeAlat,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      
      if (nama != null) updateData['nama'] = nama;
      if (kategoriId != null) updateData['kategori_id'] = kategoriId;
      if (kondisi != null) updateData['kondisi'] = kondisi;
      if (urlGambar != null) updateData['url_gambar'] = urlGambar;
      if (stok != null) updateData['stok'] = stok;
      if (kodeAlat != null) updateData['kode_alat'] = kodeAlat;
      if (status != null) updateData['status'] = status;

      await _supabase
          .from('alat')
          .update(updateData)
          .eq('id', id);
      
      return true;
    } catch (e) {
      print("ERROR UPDATE ALAT: $e");
      return false;
    }
  }

  Future<bool> deleteAlat(int id) async {
    try {
      await _supabase
          .from('alat')
          .delete()
          .eq('id', id);
      
      return true;
    } catch (e) {
      print("ERROR DELETE ALAT: $e");
      rethrow;
    }
  }

  Future<List<Alat>> searchAlat(String searchTerm) async {
    try {
      final response = await _supabase
          .from('alat')
          .select('*, kategori:kategori_alat(*)')
          .ilike('nama', '%$searchTerm%')
          .order('nama');
      
      return response.map((e) => Alat.fromJson(e)).toList();
    } catch (e) {
      print("ERROR SEARCH ALAT: $e");
      rethrow;
    }
  }

  Future<List<KategoriAlat>> getKategoriOptions() async {
    try {
      final response = await _supabase
          .from('kategori_alat')
          .select('*')
          .order('nama');
      
      return response.map((e) => KategoriAlat.fromJson(e)).toList();
    } catch (e) {
      print("ERROR FETCH KATEGORI OPTIONS: $e");
      rethrow;
    }
  }

  // 🔥 UPLOAD IMAGE KE STORAGE
   Future<String> uploadImage(dynamic file) async {
    try {
      print('DEBUG: Starting uploadImage function');
      print('DEBUG: File type: ${file.runtimeType}');
      print('DEBUG: Platform is web: $kIsWeb');
      
      if (kIsWeb) {
        // Di web, kita terima XFile dari image_picker
        print('DEBUG: Web platform detected');
        
        if (file is XFile) {
          print('DEBUG: Processing XFile on web');
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.name)}';
          
          // Di web, XFile.readAsBytes() tersedia
          final bytes = await file.readAsBytes();
          print('DEBUG: File bytes length: ${bytes.length}');
          
          // Upload ke storage
          await _supabase.storage
              .from('alat-images')
              .uploadBinary(fileName, bytes);
          
          final publicUrl = _supabase.storage.from('alat-images').getPublicUrl(fileName);
          print('DEBUG: Web upload successful, URL: $publicUrl');
          return publicUrl;
        } else {
          print('DEBUG: Invalid file type for web: ${file.runtimeType}');
          throw Exception('Invalid file type for web upload');
        }
        
      } else {
        // Di mobile, gunakan File  
        print('DEBUG: Mobile platform detected');
        
        if (file is File) {
          print('DEBUG: Processing File on mobile');
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';

          await _supabase.storage
              .from('alat-images')
              .upload(fileName, file);

          final publicUrl = _supabase.storage.from('alat-images').getPublicUrl(fileName);
          print('DEBUG: Mobile upload successful, URL: $publicUrl');
          return publicUrl;
        } else {
          print('DEBUG: Invalid file type for mobile: ${file.runtimeType}');
          throw Exception('Invalid file type for mobile upload');
        }
      }
      
    } catch (e) {
      print('ERROR UPLOAD IMAGE: $e');
      print('ERROR TYPE: ${e.runtimeType}');
      if (e is Exception) {
        print('ERROR DETAILS: ${e.toString()}');
      }
      throw Exception('Upload gambar gagal: $e');
    }
  }
}