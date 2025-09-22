import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/home_controller.dart'; // To access compareWithApi and results

class ResultScreen extends StatelessWidget {
  final String extractedText;

  const ResultScreen({super.key, required this.extractedText});

  @override
  Widget build(BuildContext context) {
    // Find the HomeController instance that's already managed by GetX
    final HomeController controller = Get.find<HomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extraction Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Extracted Text:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  extractedText.isEmpty ? "No text extracted." : extractedText,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: (extractedText.isEmpty || controller.isCallingApi.value) // Disable if no text OR if API call is in progress
                    ? null 
                    : () {
                        controller.compareWithApi(extractedText);
                      },
                child: Obx(() => controller.isCallingApi.value // Use isCallingApi for feedback
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Compare with API')),
              ),
              const SizedBox(height: 20),
              Obx(() {
                // Also, ensure API results are only shown if not loading
                if (controller.isCallingApi.value) {
                  return const SizedBox.shrink(); // Don't show old results while new ones are loading
                }
                if (controller.apiResult.value.isEmpty && controller.comparisonMessage.value.isEmpty) {
                  return const SizedBox.shrink(); // Don't show if no API results yet
                }
                return Column(
                  children: [
                    const Text(
                      'API Comparison:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text('API Info: ${controller.apiResult.value}'),
                    const SizedBox(height: 5),
                    Text('Details: ${controller.comparisonMessage.value}'),
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
