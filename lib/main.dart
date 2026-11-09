import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'VT323').copyWith(
          bodyLarge: const TextStyle(fontFamily: 'VT323', color: Color(0xFF00F0FF)),
          bodyMedium: const TextStyle(fontFamily: 'VT323', color: Color(0xFF00E5FF)),
        ),
      ),
      initialRoute: AppRoutes.initial,
      getPages: AppRoutes.routes,
    );
  }
}
