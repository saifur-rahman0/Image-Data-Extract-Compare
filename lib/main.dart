import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import the newly created files
import 'app/modules/home/home_screen.dart';
import 'app/modules/home/home_binding.dart';
// We don't need to import home_controller.dart here as it's used by HomeScreen and HomeBinding

// We can also define app routes for better organization if the app grows
// import 'app/routes/app_pages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Image Extractor App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // Or use AppPages.INITIAL if using a routes file
      getPages: [
        GetPage(
          name: '/',
          page: () => const HomeScreen(), // Use const HomeScreen
          binding: HomeBinding(),
        ),
        // Example for other routes if you create app_pages.dart
        // ...AppPages.routes,
      ],
    );
  }
}

// Placeholder classes for HomeScreen, HomeController, and HomeBinding are now removed
// as they are in their respective files.