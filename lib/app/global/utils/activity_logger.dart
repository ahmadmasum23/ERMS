import 'package:inven/app/data/services/log_aktivitas_service.dart';

class ActivityLogger {
  static final LogAktivitasService _service = LogAktivitasService();

  /// Log when an item is created
  static Future<void> logCreate({
    required String entitas,
    int? entitasId,
    Map<String, dynamic>? newData,
  }) async {
    await _service.insertLog(
      aksi: 'Created',
      entitas: entitas,
      entitasId: entitasId,
      nilaiBaru: newData,
    );
  }

  /// Log when an item is updated with detailed change tracking
  static Future<void> logUpdate({
    required String entitas,
    int? entitasId,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
  }) async {
    await _service.insertLog(
      aksi: 'Updated',
      entitas: entitas,
      entitasId: entitasId,
      nilaiLama: oldData,
      nilaiBaru: newData,
    );
  }

  /// Log when an item is deleted
  static Future<void> logDelete({
    required String entitas,
    int? entitasId,
    Map<String, dynamic>? oldData,
  }) async {
    await _service.insertLog(
      aksi: 'Deleted',
      entitas: entitas,
      entitasId: entitasId,
      nilaiLama: oldData,
    );
  }

  /// Log when a loan is submitted
  static Future<void> logLoanSubmission(int loanId) async {
    await _service.insertLog(
      aksi: 'Submitted',
      entitas: 'Peminjaman',
      entitasId: loanId,
    );
  }

  /// Log when a loan is approved
  static Future<void> logLoanApproval(int loanId) async {
    await _service.insertLog(
      aksi: 'Approved',
      entitas: 'Peminjaman',
      entitasId: loanId,
    );
  }

  /// Log when a loan is rejected
  static Future<void> logLoanRejection(int loanId) async {
    await _service.insertLog(
      aksi: 'Rejected',
      entitas: 'Peminjaman',
      entitasId: loanId,
    );
  }

  /// Log when a return is confirmed
  static Future<void> logReturnConfirmation(int loanId) async {
    await _service.insertLog(
      aksi: 'Confirmed Return',
      entitas: 'Peminjaman',
      entitasId: loanId,
    );
  }

  /// Log when a user is created
  static Future<void> logUserCreation(String userId, String userName) async {
    await _service.insertLog(
      aksi: 'Created',
      entitas: 'User',
      penggunaId: userId,
      nilaiBaru: {'nama': userName},
    );
  }

  /// Log when a user is updated
  static Future<void> logUserUpdate(String userId, String userName) async {
    await _service.insertLog(
      aksi: 'Updated',
      entitas: 'User',
      penggunaId: userId,
      nilaiBaru: {'nama': userName},
    );
  }

  /// Helper method to compare two maps and create detailed change logs
  static Map<String, dynamic> createChangeLog(
    Map<String, dynamic> oldData, 
    Map<String, dynamic> newData
  ) {
    Map<String, dynamic> changes = {};
    
    // Check for added/modified fields
    newData.forEach((key, newValue) {
      if (oldData.containsKey(key)) {
        var oldValue = oldData[key];
        if (oldValue != newValue) {
          changes[key] = {'from': oldValue, 'to': newValue};
        }
      } else {
        changes[key] = {'from': null, 'to': newValue};
      }
    });
    
    // Check for removed fields
    oldData.forEach((key, oldValue) {
      if (!newData.containsKey(key)) {
        changes[key] = {'from': oldValue, 'to': null};
      }
    });
    
    return changes;
  }

  /// Log detailed update with automatic change detection
  static Future<void> logDetailedUpdate({
    required String entitas,
    int? entitasId,
    required Map<String, dynamic> oldData,
    required Map<String, dynamic> newData,
  }) async {
    final changes = createChangeLog(oldData, newData);
    
    if (changes.isNotEmpty) {
      await _service.insertLog(
        aksi: 'Updated',
        entitas: entitas,
        entitasId: entitasId,
        nilaiLama: oldData,
        nilaiBaru: newData,
      );
    }
  }
}