import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import '../models/AppAlat.dart';
import '../models/AppKategori.dart';

class AlatService {
  final SupabaseClient _supabase = AuthService().client;

  Future<List<AppAlat>> getAllAlat() async {
    try {
      final response = await _supabase
          .from('alat')
          .select('*, kategori:kategori_id(*)')
          .order('nama');
      
      return response
          .map((e) => AppAlat.fromJson(e))
          .toList();
    } catch (e) {
      print("ERROR FETCH ALAT: $e");
      rethrow;
    }
  }

  Future<AppAlat?> getAlatById(int id) async {
    try {
      final response = await _supabase
          .from('alat')
          .select('*, kategori:kategori_id(*)')
          .eq('id', id)
          .single();
      
      return AppAlat.fromJson(response);
    } catch (e) {
      print("ERROR FETCH ALAT BY ID: $e");
      return null;
    }
  }

  Future<List<AppAlat>> getAlatByKategori(int kategoriId) async {
    try {
      final response = await _supabase
          .from('alat')
          .select('*, kategori:kategori_id(*)')
          .eq('kategori_id', kategoriId)
          .order('nama');
      
      return response
          .map((e) => AppAlat.fromJson(e))
          .toList();
    } catch (e) {
      print("ERROR FETCH ALAT BY KATEGORI: $e");
      rethrow;
    }
  }

  Future<AppAlat> createAlat({
    required String nama,
    int? kategoriId,
    required String kondisi,
    String? urlGambar,
    int stok = 1,
  }) async {
    try {
      final response = await _supabase
          .from('alat')
          .insert({
            'nama': nama,
            'kategori_id': kategoriId,
            'kondisi': kondisi,
            'url_gambar': urlGambar,
            'stok': stok,
          })
          .select('*, kategori:kategori_id(*)')
          .single();
      
      return AppAlat.fromJson(response);
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
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      
      if (nama != null) updateData['nama'] = nama;
      if (kategoriId != null) updateData['kategori_id'] = kategoriId;
      if (kondisi != null) updateData['kondisi'] = kondisi;
      if (urlGambar != null) updateData['url_gambar'] = urlGambar;
      if (stok != null) updateData['stok'] = stok;

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

  Future<List<AppAlat>> searchAlat(String searchTerm) async {
    try {
      final response = await _supabase
          .from('alat')
          .select('*, kategori:kategori_id(*)')
          .ilike('nama', '%$searchTerm%')
          .order('nama');
      
      return response
          .map((e) => AppAlat.fromJson(e))
          .toList();
    } catch (e) {
      print("ERROR SEARCH ALAT: $e");
      rethrow;
    }
  }

  Future<List<AppKategori>> getKategoriOptions() async {
    try {
      final response = await _supabase
          .from('kategori_alat')
          .select('*')
          .order('nama');
      
      return response
          .map((e) => AppKategori.fromJson(e))
          .toList();
    } catch (e) {
      print("ERROR FETCH KATEGORI OPTIONS: $e");
      rethrow;
    }
  }
}