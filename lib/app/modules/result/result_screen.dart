import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/home_controller.dart'; // To access compareWithApi and results

class ResultScreen extends StatelessWidget {
  final String extractedText;

  const ResultScreen({super.key, required this.extractedText});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final ThemeData theme = Theme.of(context); // Access theme for consistent styling

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extraction Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView( // Use ListView for scrollability
          children: <Widget>[
            // --- Extracted Text Card ---
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Extracted Text from Image:',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        extractedText.isEmpty ? "No text could be extracted." : extractedText,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- Compare Button ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: theme.textTheme.titleMedium,
              ),
              onPressed: (extractedText.isEmpty || controller.isCallingApi.value)
                  ? null
                  : () {
                      controller.compareWithApi(extractedText);
                    },
              child: Obx(() => controller.isCallingApi.value
                  ? const SizedBox(
                      height: 24, // Consistent height for indicator
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                    )
                  : const Text('Compare with API')),
            ),

            const SizedBox(height: 24),

            // --- API Comparison Results Card ---
            Obx(() {
              if (controller.isCallingApi.value) {
                // Optionally show a placeholder or a different loading indicator for the card
                return const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text("Fetching API data...", style: TextStyle(fontStyle: FontStyle.italic)),
                ));
              }
              if (controller.apiResult.value.isEmpty && controller.comparisonMessage.value.isEmpty) {
                return const SizedBox.shrink(); // Don't show card if no API results yet
              }

              Color comparisonColor = theme.textTheme.bodyLarge?.color ?? Colors.black; // Default color
              String comparisonText = controller.comparisonMessage.value;

              if (comparisonText.startsWith('Temperatures match!')) {
                comparisonColor = Colors.green.shade700;
              } else if (comparisonText.startsWith('Temperatures differ.')) {
                comparisonColor = Colors.red.shade700;
              } else if (controller.apiResult.value == 'Could not find a temperature in the image text.' ||
                         controller.apiResult.value == 'API Call Failed.') {
                comparisonColor = Colors.orange.shade700;
              }


              return Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'API Comparison:',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      if (controller.apiResult.value.isNotEmpty) ...[
                        Text(
                          controller.apiResult.value,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (comparisonText.isNotEmpty)
                        Text(
                          comparisonText,
                          style: theme.textTheme.bodyLarge?.copyWith(color: comparisonColor, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
