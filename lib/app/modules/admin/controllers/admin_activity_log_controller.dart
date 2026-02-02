import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inven/app/data/models/LogAktivitas.dart';
import 'package:inven/app/data/services/log_aktivitas_service.dart';

class AdminActivityLogController extends GetxController {
  final LogAktivitasService _logService = LogAktivitasService();

  var logs = <LogAktivitas>[].obs;
  var isLoading = false.obs;
  var searchController = TextEditingController();
  var selectedAction = ''.obs;
  var selectedEntity = ''.obs;

  // Filter options
  var actionOptions = <String>[].obs;
  var entityOptions = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _insertSampleData(); // Insert sample data on first load
    fetchLogs();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> _insertSampleData() async {
    try {
      // Check if we already have data
      final existingLogs = await _logService.getAllLogs();
      if (existingLogs.isNotEmpty) return;

      // Insert sample logs
      await _logService.insertLog(
        aksi: 'Created',
        entitas: 'Alat',
        entitasId: 1,
        nilaiBaru: {'nama': 'Laptop ASUS ROG', 'kategori': 'Elektronik'},
      );
      
      await _logService.insertLog(
        aksi: 'Updated',
        entitas: 'Alat',
        entitasId: 2,
        nilaiLama: {'stok': 5},
        nilaiBaru: {'stok': 3},
      );
      
      await _logService.insertLog(
        aksi: 'Submitted',
        entitas: 'Peminjaman',
        entitasId: 101,
      );
      
      await _logService.insertLog(
        aksi: 'Approved',
        entitas: 'Peminjaman',
        entitasId: 101,
      );
      
      await _logService.insertLog(
        aksi: 'Created',
        entitas: 'User',
        nilaiBaru: {'nama': 'Budi Santoso', 'peran': 'peminjam'},
      );
      
      await _logService.insertLog(
        aksi: 'Confirmed Return',
        entitas: 'Peminjaman',
        entitasId: 101,
      );
      
      print('✅ Sample activity logs inserted');
    } catch (e) {
      print('ℹ️ Sample data already exists or error: $e');
    }
  }

  Future<void> fetchLogs() async {
    try {
      isLoading.value = true;
      
      final result = await _logService.getAllLogs();
      logs.assignAll(result); // Use assignAll instead of direct assignment
      
      print("SUCCESS: Loaded ${logs.length} activity logs");
    } catch (e) {
      logs.clear();
      Get.snackbar(
        "Error",
        "Failed to load activity logs",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      print("ERROR FETCH LOGS: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String value) {
    // Simple debounce - in a real app you'd use a proper debouncer
    Future.delayed(const Duration(milliseconds: 300), () {
      if (value == searchController.text) {
        _applyFilters();
      }
    });
  }

  void onActionFilterChanged(String? value) {
    selectedAction.value = value ?? '';
    _applyFilters();
  }

  void onEntityFilterChanged(String? value) {
    selectedEntity.value = value ?? '';
    _applyFilters();
  }

  void _applyFilters() {
    // Filtering will be done in the service in future iterations
    fetchLogs();
  }

  void refreshLogs() {
    searchController.clear();
    selectedAction.value = '';
    selectedEntity.value = '';
    fetchLogs();
  }

  // Helper method to get filtered logs for UI
  List<LogAktivitas> get filteredLogs {
    List<LogAktivitas> result = [];
    
    // Make sure logs is not empty before processing
    if (logs.isNotEmpty) {
      result = List.from(logs);
      
      // Apply search filter
      if (searchController.text.isNotEmpty) {
        final searchTerm = searchController.text.toLowerCase();
        result = result.where((log) =>
          (log.aksi?.toLowerCase().contains(searchTerm) ?? false) ||
          (log.entitas?.toLowerCase().contains(searchTerm) ?? false) ||
          (log.namaPengguna != null && log.namaPengguna!.toLowerCase().contains(searchTerm))
        ).toList();
      }
      
      // Apply action filter
      if (selectedAction.value.isNotEmpty) {
        result = result.where((log) => log.aksi == selectedAction.value).toList();
      }
      
      // Apply entity filter
      if (selectedEntity.value.isNotEmpty) {
        result = result.where((log) => log.entitas == selectedEntity.value).toList();
      }
    }
    
    return result;
  }

  // Get unique actions for filter dropdown
  List<String> getUniqueActions() {
    if (logs.isEmpty) return [];
    return logs.map((log) => log.aksi ?? '').where((aksi) => aksi.isNotEmpty).toSet().toList();
  }

  // Get unique entities for filter dropdown
  List<String> getUniqueEntities() {
    if (logs.isEmpty) return [];
    return logs.map((log) => log.entitas).toSet().toList();
  }
}