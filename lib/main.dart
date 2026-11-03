import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'The Index - Prescript Device',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF000000),
        textTheme: GoogleFonts.vt323TextTheme(ThemeData.dark().textTheme).copyWith(
          bodyLarge: GoogleFonts.vt323(color: const Color(0xFF00F0FF)),
          bodyMedium: GoogleFonts.vt323(color: const Color(0xFF00E5FF)),
        ),
      ),
      initialRoute: AppRoutes.initial,
      getPages: AppRoutes.routes,
    );
  }
}
