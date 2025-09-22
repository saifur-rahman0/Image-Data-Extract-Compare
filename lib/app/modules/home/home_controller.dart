import 'package:get/get.dart';

class HomeController extends GetxController {
  // Observables for UI updates
  var selectedImagePath = ''.obs;
  var extractedText = ''.obs;
  var apiResult = ''.obs;
  var comparisonMessage = ''.obs;
  var isLoading = false.obs;

  // TODO: Implement image picking logic (e.g., using image_picker package)
  void pickImage() async {
    isLoading.value = true;
    // Simulate image picking
    await Future.delayed(const Duration(seconds: 1));
    selectedImagePath.value = 'path/to/gallery/image.jpg';
    // After picking, extract text
    extractTextFromImage(selectedImagePath.value);
    isLoading.value = false;
  }

  // TODO: Implement photo taking logic (e.g., using image_picker package)
  void takePhoto() async {
    isLoading.value = true;
    // Simulate photo taking
    await Future.delayed(const Duration(seconds: 1));
    selectedImagePath.value = 'path/to/camera/image.jpg';
    // After taking photo, extract text
    extractTextFromImage(selectedImagePath.value);
    isLoading.value = false;
  }

  // TODO: Implement OCR logic (e.g., using google_ml_kit or other OCR package)
  void extractTextFromImage(String imagePath) async {
    if (imagePath.isEmpty) return;
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Simulate OCR
    extractedText.value = 'Sample Text 28C'; // Example extracted text
    // After extracting text, compare with API
    compareWithApi(extractedText.value);
    isLoading.value = false;
  }

  // TODO: Implement API call and comparison logic (e.g., using http package and a public API)
  void compareWithApi(String text) async {
    if (text.isEmpty) return;
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    // Example: if text contains a temperature
    if (text.toLowerCase().contains('28c') || text.toLowerCase().contains('28°c')) {
      apiResult.value = 'API: Current temp in CityX is 25C'; // Replace with actual API call
      comparisonMessage.value = 'Difference detected: Image 28C, API 25C';
    } else {
      apiResult.value = 'API: Could not find relevant info for "$text"';
      comparisonMessage.value = 'No comparison performed.';
    }
    isLoading.value = false;
  }
}