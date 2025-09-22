import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart'; // Import the controller

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Data Extractor'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() { // Wrap Column with Obx to react to isProcessingImage
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Make buttons stretch
              children: <Widget>[
                ElevatedButton(
                  onPressed: controller.isProcessingImage.value
                      ? null // Disable if processing
                      : () {
                          controller.pickImage();
                        },
                  child: const Text('Pick Image from Gallery'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.isProcessingImage.value
                      ? null // Disable if processing
                      : () {
                          controller.takePhoto();
                        },
                  child: const Text('Take Photo'),
                ),
                const SizedBox(height: 30),
                if (controller.isProcessingImage.value) // Show indicator if processing
                  const Center(child: CircularProgressIndicator()),
              ],
            );
          }),
        ),
      ),
    );
  }
}
