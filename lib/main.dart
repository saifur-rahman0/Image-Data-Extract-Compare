import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import AppPages which handles all routes and their respective screens/bindings
import 'app/routes/app_pages.dart';

// No longer need direct imports for HomeScreen and HomeBinding here
// import 'app/modules/home/home_screen.dart';
// import 'app/modules/home/home_binding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'OCR', // Changed app title
      debugShowCheckedModeBanner: false, // Added this line
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppPages.INITIAL, // Use initial route from AppPages
      getPages: AppPages.routes,      // Use all routes defined in AppPages
    );
  }
}
