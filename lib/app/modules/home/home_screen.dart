import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart'; // Import the controller

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key}); // Added const and super.key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Data Extractor'),
      ),
      body: Center(
        child: Padding( // Added padding for better spacing
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  controller.pickImage();
                },
                child: const Text('Pick Image from Gallery'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  controller.takePhoto();
                },
                child: const Text('Take Photo'),
              ),
              const SizedBox(height: 30),
              Obx(() {
                if (controller.isLoading.value) {
                  return const CircularProgressIndicator();
                }
                return Column(
                  children: [
                    Text('Selected Image: ${controller.selectedImagePath.value}'),
                    const SizedBox(height: 10),
                    Text('Extracted Text: ${controller.extractedText.value}'),
                    const SizedBox(height: 10),
                    Text('API Result: ${controller.apiResult.value}'),
                    const SizedBox(height: 10),
                    Text('Comparison: ${controller.comparisonMessage.value}'),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}