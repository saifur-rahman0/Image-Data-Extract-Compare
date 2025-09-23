import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'result_controller.dart';

class ResultScreen extends GetView<ResultController> {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.black45,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                ),
                onPressed: isEffectivelyDisabled ? null : () {
                  controller.performApiComparison();
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: isEffectivelyDisabled && !isLoading
                        ? LinearGradient(
                            colors: [Colors.grey.shade400, Colors.grey.shade600],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    constraints: const BoxConstraints(minHeight: 50),
                    alignment: Alignment.center,
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
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
            Obx(() {
              Widget cardContent;

              if (!controller.isCallingApi.value && !controller.temperatureProcessingAttempted.value) {
                cardContent = const SizedBox.shrink(key: ValueKey('apiCardInitialHidden'));
              } else if (controller.isCallingApi.value && !controller.temperatureProcessingAttempted.value) {
                cardContent = const Center(
                  key: ValueKey('apiLoading'),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text("Fetching API data...", style: TextStyle(fontStyle: FontStyle.italic)),
                  ),
                );
              } else if (controller.temperatureProcessingAttempted.value &&
                         (controller.overallTemperatureStatusMessage.value.isNotEmpty ||
                          controller.temperatureComparisonResult.value.isNotEmpty ||
                          controller.temperatureDifferenceDetails.value.isNotEmpty ||
                          controller.imageTemperature.value != null)) {
                
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
                // Use overallTemperatureStatusMessage for error status
                bool isErrorStatus = controller.overallTemperatureStatusMessage.value.contains('Could not find') ||
                                     controller.overallTemperatureStatusMessage.value.contains('API Error') ||
                                     controller.overallTemperatureStatusMessage.value.contains('API Call Failed') ||
                                     controller.overallTemperatureStatusMessage.value.contains('Weather API Call Failed');
                if (isErrorStatus) {
                  overallStatusColor = Colors.orange.shade700;
                  if (cardBackgroundColor == null) {
                    cardBackgroundColor = Colors.orange.shade50;
                  }
                }

                bool showTempColumns = controller.imageTemperature.value != null && controller.apiTemperature.value != null;

                cardContent = Card(
                  key: const ValueKey('apiCardData'),
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
                        if (controller.overallTemperatureStatusMessage.value.isNotEmpty)
                          Text(
                            controller.overallTemperatureStatusMessage.value,
                            style: theme.textTheme.titleMedium?.copyWith(color: overallStatusColor),
                            textAlign: TextAlign.center,
                          ),
                        if (controller.overallTemperatureStatusMessage.value.isNotEmpty) const SizedBox(height: 16),
                        
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
              } else {
                cardContent = const SizedBox.shrink(key: ValueKey('apiCardEmptyAfterAttempt'));
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: cardContent,
              );
            }),

            const SizedBox(height: 24),

            // --- Identified Products Card ---
            Obx(() {
              Widget productCardContent;

              if (!controller.isCallingApi.value && !controller.productSearchAttempted.value) {
                productCardContent = const SizedBox.shrink(key: ValueKey('productCardInitialHidden'));
              } else if (controller.isCallingApi.value &&
                         controller.temperatureProcessingAttempted.value && 
                         !controller.productSearchAttempted.value) {
                // Show loading if API is active, temp processing is done (or was attempted),
                // and product search hasn't been attempted yet.
                productCardContent = const Center(
                  key: ValueKey('productLoadingIndicator'),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text("Identifying products in text...", style: TextStyle(fontStyle: FontStyle.italic)),
                  ),
                );
              } else if (controller.productSearchAttempted.value) {
                if (controller.identifiedProductNames.isNotEmpty) { // Or use controller.productsWereFound.value
                  productCardContent = Card(
                    key: const ValueKey('productsCardData'),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    color: Colors.teal.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Identified Potential Products',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal.shade800),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.identifiedProductNames.length,
                            itemBuilder: (context, index) {
                              final productName = controller.identifiedProductNames[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  '- $productName',
                                  style: theme.textTheme.bodyLarge?.copyWith(color: Colors.teal.shade700),
                                  textAlign: TextAlign.start,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  productCardContent = Card(
                    key: const ValueKey('noProductsFoundMessageCard'),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    color: Colors.amber.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Product Identification',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.amber.shade800),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No specific products identified in the text.',
                            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.amber.shade700),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
              } else {
                productCardContent = const SizedBox.shrink(key: ValueKey('productCardHiddenFallback'));
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(sizeFactor: animation, axis: Axis.vertical, child: child),
                  );
                },
                child: productCardContent,
              );
            }),
          ],
        ),
      ),
    );
  }
}
