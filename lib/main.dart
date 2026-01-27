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
  await initializeDateFormatting('id_ID', null);
  await GetStorage.init();
  
  // Initialize database connection
  try {
    await DatabaseServiceProvider.initialize();
  } catch (e) {
    print('Database initialization failed: $e');
  }

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