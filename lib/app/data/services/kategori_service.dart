import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import '../models/KategoriAlat.dart';

class KategoriService {
  final SupabaseClient _supabase = AuthService().client;

  Future<List<KategoriAlat>> getAllKategori() async {
    try {
      final response = await _supabase
          .from('kategori_alat')
          .select()
          .order('nama');
      
      return response.map((e) => KategoriAlat.fromJson(e)).toList();
    } catch (e) {
      print("ERROR FETCH KATEGORI: $e");
      rethrow;
    }
  }

  Future<KategoriAlat?> getKategoriById(int id) async {
    try {
      final response = await _supabase
          .from('kategori_alat')
          .select()
          .eq('id', id)
          .limit(1);
      
      if (response.isEmpty) return null;
      return KategoriAlat.fromJson(response.first);
    } catch (e) {
      print("ERROR FETCH KATEGORI BY ID: $e");
      return null;
    }
  }

  Future<KategoriAlat> createKategori({
    required String kode,
    required String nama,
  }) async {
    try {
      final response = await _supabase
          .from('kategori_alat')
          .insert({
            'kode': kode,
            'nama': nama,
          })
          .select()
          .limit(1);
      
      if (response.isEmpty) throw Exception('Failed to create kategori');
      return KategoriAlat.fromJson(response.first);
    } catch (e) {
      print("ERROR CREATE KATEGORI: $e");
      rethrow;
    }
  }

  Future<bool> updateKategori({
    required int id,
    required String kode,
    required String nama,
  }) async {
    try {
      await _supabase
          .from('kategori_alat')
          .update({
            'kode': kode,
            'nama': nama,
          })
          .eq('id', id);
      
      return true;
    } catch (e) {
      print("ERROR UPDATE KATEGORI: $e");
      return false;
    }
  }

  Future<bool> deleteKategori(int id) async {
    try {
      // Check if kategori is being used by any alat
      final alatCount = await _supabase
          .from('alat')
          .select('id')
          .eq('kategori_id', id);
      
      if ((alatCount as List).isNotEmpty) {
        throw Exception('Kategori ini masih digunakan oleh alat-alat');
      }

      await _supabase
          .from('kategori_alat')
          .delete()
          .eq('id', id);
      
      return true;
    } catch (e) {
      print("ERROR DELETE KATEGORI: $e");
      rethrow;
    }
  }

  Future<int> getAlatCountByKategori(int kategoriId) async {
    try {
      final response = await _supabase
          .from('alat')
          .select('id')
          .eq('kategori_id', kategoriId);
      
      return (response as List).length;
    } catch (e) {
      print("ERROR GET ALAT COUNT: $e");
      return 0;
    }
  }
}