import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart'; // Import the controller

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row( // New title with logo
          children: [
            Image.asset(
              'assets/logo/app_logo.png',
              height: 30, // Adjust height as needed
              // width: 30, // Optionally set width
            ),
            const SizedBox(width: 8), // Spacing between logo and text
            const Text('Image Data Extractor'),
          ],
        ),
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove AppBar shadow
      ),
      extendBodyBehindAppBar: true, // Extend body behind AppBar for full screen background
      body: Container( // Wrap with Container for background image
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/bg.jpg'), // Your image path
            fit: BoxFit.cover, // Changed back to BoxFit.cover
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.85), // Semi-transparent white
                      foregroundColor: Colors.black87, // Text color
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: controller.isProcessingImage.value
                        ? null
                        : () {
                            controller.pickImage();
                          },
                    child: const Text('Pick Image from Gallery'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.85), // Semi-transparent white
                      foregroundColor: Colors.black87, // Text color
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: controller.isProcessingImage.value
                        ? null
                        : () {
                            controller.takePhoto();
                          },
                    child: const Text('Take Photo'),
                  ),
                  const SizedBox(height: 30),
                  if (controller.isProcessingImage.value)
                    const Center(child: CircularProgressIndicator(color: Colors.white)), // White indicator
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
