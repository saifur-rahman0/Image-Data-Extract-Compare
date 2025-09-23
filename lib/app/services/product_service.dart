import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  final String _apiUrl = 'https://api-inference.huggingface.co/models/dslim/bert-base-NER';
  final String _apiKey;

  ProductService({required String apiKey}) : _apiKey = apiKey;

  Future<List<String>> findProductEntities(String inputText) async {
    if (inputText.isEmpty) {
      return [];
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'inputs': inputText}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body);
        final List<String> productNames = [];
        for (var entity in results) {
          // You might want to refine this logic based on typical product entity types
          // For dslim/bert-base-NER, 'ORG' (organization) and 'MISC' (miscellaneous)
          // might contain product names, or even 'PRODUCT' if the model supports it.
          // Let's be a bit broad for now and collect ORG, MISC, and PRODUCT if they appear.
          String entityGroup = entity['entity_group'] ?? '';
          if (entity['word'] != null && 
              (entityGroup == 'ORG' || entityGroup == 'MISC' || entityGroup == 'PRODUCT' || entityGroup == 'PROD')) {
            productNames.add(entity['word']);
          }
        }
        print(inputText);
        print(productNames);
        // Remove duplicates if any
        return productNames.toSet().toList();
      } else {
        // Consider logging the error or throwing a more specific exception
        print('Hugging Face API Error: ${response.statusCode} - ${response.body}');
        return []; // Or throw an exception
      }
    } catch (e) {
      print('Error calling Hugging Face API: $e');
      return []; // Or throw an exception
    }
  }
}
