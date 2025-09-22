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
              'assets/logo/applogo.png',
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
            image: AssetImage('assets/background/bg2.jpg'), // Your image path
            fit: BoxFit.cover, // Changed back to BoxFit.cover
          ),
        ),
        child: Align( // Changed from Center to Align
          alignment: Alignment.center, // Aligns child to the bottom center
          child: Padding(
            // Adjusted padding to give more space at the bottom
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 48.0),
            child: Obx(() {
              return Column(
                mainAxisSize: MainAxisSize.min, // Changed from MainAxisAlignment.center
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
                  // Keep the progress indicator logic if it should also be at the bottom
                  if (controller.isProcessingImage.value)
                    const Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Center(child: CircularProgressIndicator(color: Colors.white)), // White indicator
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
