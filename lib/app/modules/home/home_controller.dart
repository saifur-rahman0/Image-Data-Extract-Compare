import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// Updated controller imports
import '../controllers/temperature_controller.dart';
import '../controllers/product_controller.dart';
import '../../routes/app_routes.dart'; // Keep for navigation

class HomeController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final TemperatureController _temperatureController = Get.find<TemperatureController>();
  final ProductController _productController = Get.find<ProductController>();

  // Rx variables that remain in HomeController
  var selectedImagePath = ''.obs;
  var extractedText = ''.obs; 
  final RxString ocrTextForResultScreen = ''.obs;
  var isProcessingImage = false.obs;
  var isCallingApi = false.obs; 

  HomeController();

  @override
  void onClose() {
    _textRecognizer.close();
    super.onClose();
  }

  void _resetAllLogicFields() {
    _temperatureController.resetFields();
    _productController.resetFields();
  }

  Future<void> _initiateImageProcessing(ImageSource source) async {
    isProcessingImage.value = true;
    selectedImagePath.value = '';
    extractedText.value = ''; 
    ocrTextForResultScreen.value = '';
    _resetAllLogicFields(); 

    try {
      final XFile? imageFile = await _picker.pickImage(source: source);
      if (imageFile != null) {
        selectedImagePath.value = imageFile.path;
        await _extractTextAndNavigate(imageFile.path);
      } else {
        Get.snackbar('Info', source == ImageSource.camera ? 'No photo taken.' : 'No image selected.', duration: const Duration(seconds: 1));
        isProcessingImage.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to ${source == ImageSource.camera ? "take photo" : "pick image"}: ${e.toString()}', duration: const Duration(seconds: 1));
      isProcessingImage.value = false;
    }
  }

  Future<void> pickImage() async {
    await _initiateImageProcessing(ImageSource.gallery);
  }

  Future<void> takePhoto() async {
    await _initiateImageProcessing(ImageSource.camera);
  }

  Future<void> _extractTextAndNavigate(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      String text = recognizedText.text;
      if (text.isNotEmpty) {
        extractedText.value = text; 
        ocrTextForResultScreen.value = text; 
        Get.toNamed(Routes.RESULT);
      } else {
        extractedText.value = 'No text found in the image.';
        ocrTextForResultScreen.value = 'No text found in the image.';
        Get.snackbar('OCR Result', 'No text found in the image.', duration: const Duration(seconds: 1));
      }
    } catch (e) {
      String errorMsg = 'Failed to extract text: ${e.toString()}';
      extractedText.value = errorMsg;
      ocrTextForResultScreen.value = errorMsg;
      Get.snackbar('Error', errorMsg, duration: const Duration(seconds: 1));
    } finally {
      isProcessingImage.value = false;
    }
  }

  Future<void> compareWithApi(String imageText) async {
    if (imageText.isEmpty) {
      Get.snackbar('Info', 'No text provided for API comparison.', duration: const Duration(seconds: 1));
      _resetAllLogicFields();
      isCallingApi.value = false; // Ensure isCallingApi is reset
      return;
    }

    _resetAllLogicFields();
    isCallingApi.value = true;

    // --- Temperature Processing ---
    await _temperatureController.processAndCompare(imageText);

    if (_temperatureController.temperatureFoundInImage.value) {
       Get.snackbar(
        'OCR Success',
        'Temperature found: ${_temperatureController.imageTemperature.value?.toStringAsFixed(1)}°C. Comparing with API...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.lightGreen[100],
        colorText: Colors.green[700],
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
        duration: const Duration(seconds: 1),
      );
    }
    
    // --- Product Processing (runs unconditionally after temperature processing) ---
    Get.snackbar('Product Search', 'Attempting to identify products in text...',
                 snackPosition: SnackPosition.BOTTOM,
                 duration: const Duration(seconds: 1),
                 backgroundColor: Colors.blue[100],
                 colorText: Colors.blue[700]);
    try {
      await _productController.searchForProducts(imageText);

      if (_productController.productsWereFound.value) {
        Get.snackbar('Product Search', 'Found products: ${_productController.identifiedProductNames.join(', ')}',
                     snackPosition: SnackPosition.BOTTOM,
                     backgroundColor: Colors.lightGreen[100],
                     colorText: Colors.green[700],
                     duration: const Duration(seconds: 1));
      } else if (_productController.productSearchAttempted.value) {
        Get.snackbar('Product Search', 'No specific products identified in the text.',
                     snackPosition: SnackPosition.BOTTOM,
                     duration: const Duration(seconds: 1));
      }
    } catch (e) {
      Get.snackbar('Product Search Error', 'Could not identify products: ${e.toString()}',
                   snackPosition: SnackPosition.BOTTOM,
                   duration: const Duration(seconds: 1));
      _productController.productSearchAttempted.value = true;
      _productController.productsWereFound.value = false;
    }
    
    isCallingApi.value = false;
  }

  // --- Getters to expose sub-controller fields for ResultController ---
  Rxn<double> get imageTemperature => _temperatureController.imageTemperature;
  Rxn<double> get apiTemperature => _temperatureController.apiTemperature;
  RxString get apiCityName => _temperatureController.apiCityName;
  RxString get overallTemperatureStatusMessage => _temperatureController.overallTemperatureStatusMessage;
  RxString get temperatureComparisonResult => _temperatureController.temperatureComparisonResult;
  RxString get temperatureDifferenceDetails => _temperatureController.temperatureDifferenceDetails;
  RxBool get temperatureProcessingAttempted => _temperatureController.temperatureProcessingAttempted;
  RxBool get temperatureFoundInImage => _temperatureController.temperatureFoundInImage;

  RxList<String> get identifiedProductNames => _productController.identifiedProductNames;
  RxBool get productSearchAttempted => _productController.productSearchAttempted;
  RxBool get productsWereFound => _productController.productsWereFound;

}
