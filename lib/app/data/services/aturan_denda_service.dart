import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import '../models/AturanDenda.dart';

class AturanDendaService {
  final SupabaseClient _supabase = AuthService().client;

  /// 🔹 GET ALL
  Future<List<AturanDenda>> getAllAturan() async {
    final response = await _supabase
        .from('aturan_denda')
        .select()
        .order('id', ascending: false);

    return (response as List)
        .map((e) => AturanDenda.fromJson(e))
        .toList();
  }

  /// 🔹 INSERT
  Future<void> insertAturan(AturanDenda data) async {
    await _supabase.from('aturan_denda').insert({
      'jenis': data.jenis,
      'jumlah': data.jumlah,
      'keterangan': data.keterangan,
    });
  }

  /// 🔹 UPDATE
  Future<void> updateAturan(AturanDenda data) async {
    await _supabase
        .from('aturan_denda')
        .update({
          'jenis': data.jenis,
          'jumlah': data.jumlah,
          'keterangan': data.keterangan,
        })
        .eq('id', data.id);
  }

  /// 🔹 DELETE
  Future<void> deleteAturan(int id) async {
    await _supabase.from('aturan_denda').delete().eq('id', id);
  }
}
