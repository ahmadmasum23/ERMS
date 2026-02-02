import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import '../models/Alat.dart';
import '../models/KategoriAlat.dart';

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
      
      final response = await _supabase
          .from('alat')
          .insert(insertData)
          .select('*, kategori:kategori_alat(*)')
          .limit(1);
      
      if (response.isEmpty) throw Exception('Failed to create alat');
      return Alat.fromJson(response.first);
    } catch (e) {
      print("ERROR CREATE ALAT: $e");
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
}