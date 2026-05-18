import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:emecexpo/model/exhibitors_model.dart'; // Ensure this path is correct

class ExhibitorApiService {
  // Use the provided API URL for edition 1118
  static const String _apiUrl = "https://buzzevents.co/api/edition/1118/exposants";

  Future<List<ExhibitorsClass>> getExhibitors() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Check if API call succeeded and the 'exposants' list exists within 'data'
        if (jsonResponse['success'] == true &&
            jsonResponse['data'] != null &&
            jsonResponse['data']['exposants'] is List) { // **[CORRECTION 1]** Check if 'exposants' is a List

          // **[CORRECTION 2]** Get the list directly from the 'exposants' key inside 'data'
          final List<dynamic> exposantsJson = jsonResponse['data']['exposants'];

          // Map the JSON list to a list of ExhibitorsClass objects
          return exposantsJson.map((json) => ExhibitorsClass.fromJson(json)).toList();
        } else {
          // Handle case where API call is successful but expected data is missing or invalid
          throw Exception("API call succeeded but exposant list is missing or invalid in JSON structure.");
        }
      } else {
        // Handle HTTP error status codes
        throw Exception('Failed to load exhibitors: HTTP ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors or JSON decoding errors
      print('Error fetching exhibitors: $e');
      // Re-throw an error or return a specific error future for consumption in your UI layer
      throw Exception('Network Error or Data Parsing Failed: $e');
    }
  }
}