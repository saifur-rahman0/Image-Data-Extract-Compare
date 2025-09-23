import 'package:get/get.dart';
import '../../services/product_service.dart'; // Adjusted path

class ProductController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();

  final RxList<String> identifiedProductNames = <String>[].obs;
  // Indicates if a search was attempted. UI can use this to show "No products found" if attempted and list is empty.
  final RxBool productSearchAttempted = false.obs; 
  // A simpler flag to quickly check if any products were found.
  final RxBool productsWereFound = false.obs; 

  void resetFields() {
    identifiedProductNames.clear();
    productSearchAttempted.value = false;
    productsWereFound.value = false;
  }

  Future<void> searchForProducts(String imageText) async {
    resetFields(); // Reset at the beginning of each search
    productSearchAttempted.value = true;

    if (imageText.isEmpty) {
      // No action needed if imageText is empty, resetFields has already cleared everything.
      // The calling controller (HomeController) will decide if a snackbar for "No text" is needed.
      return;
    }

    // HomeController will be responsible for showing the "Attempting to identify products..." SnackBar.

    try {
      final List<String> products = await _productService.findProductEntities(imageText);
      if (products.isNotEmpty) {
        identifiedProductNames.assignAll(products);
        productsWereFound.value = true;
        // HomeController will show "Found products" SnackBar.
      } else {
        // HomeController will show "No specific products identified" SnackBar.
        productsWereFound.value = false;
      }
    } catch (e) {
      print("Error during product search in ProductController: $e");
      productsWereFound.value = false;
      // HomeController will show "Could not identify products" SnackBar.
      // Consider re-throwing or returning an error status if needed for more complex error handling.
    }
  }
}
