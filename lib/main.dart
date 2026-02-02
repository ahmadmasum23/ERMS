import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inven/app/data/services/database_service_provider.dart';
import 'package:inven/app/global/bindings/InitialBinding.dart';
import 'package:inven/app/global/utils/AppTheme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('DEBUG: Starting app initialization');
  
  await initializeDateFormatting('id_ID', null);
  print('DEBUG: Date formatting initialized');
  
  await GetStorage.init();
  print('DEBUG: GetStorage initialized');
  
  // Initialize database connection
  try {
    print('DEBUG: Initializing database connection');
    await DatabaseServiceProvider.initialize();
    print('DEBUG: Database connection initialized successfully');
  } catch (e) {
    print('Database initialization failed: $e');
  }

  print('DEBUG: Running app');
  runApp(
    GetMaterialApp(
      title: "Application",
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: AppTheme.SoftCreamyWhite.colorScheme,
      ),
      initialBinding: InitialBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}