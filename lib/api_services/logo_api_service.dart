// lib/api_services/logo_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class LogoApiService {
  // Confirmed API URL for the event details
  static const String _eventApiUrl = 'https://buzzevents.co/api/event/189';

  // 💡 CONFIRMED BASE URL for image assets
  static const String _imageBaseUrl = 'https://buzzevents.co/uploads/';

  /// Fetches the EMEC EXPO logo URL (small version) from the API event data.
  Future<String?> fetchLogoUrl() async {
    try {
      final response = await http.get(Uri.parse(_eventApiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true &&
            jsonResponse['data'] is List &&
            jsonResponse['data'].isNotEmpty) {

          final eventData = jsonResponse['data'][0];

          // Check for the logo field, which holds the filename (e.g., "EMEC-200X.png")
          if (eventData['logo'] is String) {
            final String logoFilename = eventData['logo'];

            // Construct the full URL using the confirmed base path
            return '$_imageBaseUrl$logoFilename';
          }
        }
        return null; // Data not found or structure is wrong
      } else {
        print('Failed to load event data. Status Code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Network error fetching logo data: $e');
      return null;
    }
  }
}