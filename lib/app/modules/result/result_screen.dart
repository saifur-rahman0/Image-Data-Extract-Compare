import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Import ResultController instead of HomeController
import 'result_controller.dart';

class ResultScreen extends GetView<ResultController> { // Changed to GetView<ResultController>
  // Removed final String extractedText;
  const ResultScreen({super.key}); // Removed required this.extractedText

  @override
  Widget build(BuildContext context) {
    // final HomeController controller = Get.find<HomeController>(); // Removed
    // The 'controller' is now an instance of ResultController, provided by GetView
    final ThemeData theme = Theme.of(context);

    Widget _buildTemperatureColumn(String title, double? tempValue) {
      return Column(
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            tempValue != null ? '${tempValue.toStringAsFixed(1)}°C' : 'N/A',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo/applogo.png',
              height: 30,
            ),
            const SizedBox(width: 8),
            const Text('Extraction Result'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
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
                      'Extracted Text from Image',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 150.0,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: SingleChildScrollView(
                        // Use controller.ocrText from ResultController
                        child: Text(
                          controller.ocrText.isEmpty ? "No text could be extracted." : controller.ocrText,
                          style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- Compare Button ---
            Obx(() {
              final bool isEffectivelyDisabled = controller.ocrText.isEmpty ||
                                               controller.ocrText.startsWith("No text found") ||
                                               controller.isCallingApi.value;
              final bool isLoading = controller.isCallingApi.value;

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero, // ElevatedButton itself has no padding
                  backgroundColor: Colors.transparent, // Transparent to show Ink's gradient
                  shadowColor: Colors.black45, // No default shadow
                  elevation: 2, // No elevation shadow
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)), // Rounded shape for the button
                ),
                onPressed: isEffectivelyDisabled ? null : () {
                  controller.performApiComparison(); // Call method on ResultController
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: isEffectivelyDisabled && !isLoading // Apply disabled gradient only if not loading
                        ? LinearGradient( // Disabled gradient
                            colors: [Colors.grey.shade400, Colors.grey.shade600],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : const LinearGradient( // Active or Loading gradient
                            colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)], // Blue to Cyan gradient
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                    borderRadius: BorderRadius.circular(30.0), // Match button shape
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0), // Internal padding for content
                    constraints: const BoxConstraints(minHeight: 50), // Ensure consistent button height
                    alignment: Alignment.center,
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min, // Row takes minimum space needed by children
                            mainAxisAlignment: MainAxisAlignment.center, // Center content horizontally
                            children: [
                              Text(
                                'Compare with API',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                            ],
                          ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // --- API Comparison Results Card ---
            Obx(() { // This Obx will now observe values from ResultController
              if (controller.isCallingApi.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text("Fetching API data...", style: TextStyle(fontStyle: FontStyle.italic)),
                  ),
                );
              }
              // Access all comparison data via ResultController instance
              if (controller.overallApiStatusMessage.value.isEmpty &&
                  controller.temperatureComparisonResult.value.isEmpty &&
                  controller.temperatureDifferenceDetails.value.isEmpty &&
                  controller.imageTemperature.value == null) {
                return const SizedBox.shrink();
              }

              Color? cardBackgroundColor;
              Color comparisonResultColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
              bool isMatch = controller.temperatureComparisonResult.value.startsWith('Temperatures match!');
              bool isDiffer = controller.temperatureComparisonResult.value.startsWith('Temperatures differ.');

              if (isMatch) {
                comparisonResultColor = Colors.green.shade700;
                cardBackgroundColor = Colors.green.shade50;
              } else if (isDiffer) {
                comparisonResultColor = Colors.red.shade700;
                cardBackgroundColor = Colors.red.shade50;
              }

              Color overallStatusColor = theme.textTheme.titleMedium?.color ?? Colors.black;
              bool isErrorStatus = controller.overallApiStatusMessage.value.contains('Could not find') ||
                                   controller.overallApiStatusMessage.value.contains('API Error') ||
                                   controller.overallApiStatusMessage.value.contains('API Call Failed');
              if (isErrorStatus) {
                overallStatusColor = Colors.orange.shade700;
                if (cardBackgroundColor == null) {
                    cardBackgroundColor = Colors.orange.shade50;
                }
              }

              bool showTempColumns = controller.imageTemperature.value != null &&
                                     controller.apiTemperature.value != null;

              return Card(
                elevation: 4.0,
                color: cardBackgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'API Comparison',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      if (controller.overallApiStatusMessage.value.isNotEmpty)
                        Text(
                          controller.overallApiStatusMessage.value,
                          style: theme.textTheme.titleMedium?.copyWith(color: overallStatusColor),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 16),

                      if (showTempColumns)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildTemperatureColumn('Image Temp', controller.imageTemperature.value)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTemperatureColumn('API / Current Temp', controller.apiTemperature.value)),
                          ],
                        ),
                      if (showTempColumns) const SizedBox(height: 16),

                      if (controller.temperatureComparisonResult.value.isNotEmpty)
                        Text(
                          controller.temperatureComparisonResult.value,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: comparisonResultColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (controller.temperatureComparisonResult.value.isNotEmpty) const SizedBox(height: 8),

                      if (controller.temperatureDifferenceDetails.value.isNotEmpty)
                        Text(
                          controller.temperatureDifferenceDetails.value,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: (isErrorStatus && !isMatch && !isDiffer)
                                   ? Colors.orange.shade700
                                   : theme.textTheme.bodyMedium?.color,
                          ),
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
