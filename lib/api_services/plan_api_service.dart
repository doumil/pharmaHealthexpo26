import 'dart:convert';
// 💡 IMPORTANT: You must have the http package imported and added to your pubspec.yaml
import 'package:http/http.dart' as http;

class FloorPlanApiService {

  // The static API endpoint URL
  static const String _apiUrl = 'https://buzzevents.co/api/edition/654/plan';

  // You can remove this static field as the URL is now dynamic,
  // but if other parts of your app use it, keep it until they are updated.
  // static const String floorPlanImageUrl = 'https://buzzevents.co/uploads/Emecexpo2025Plan.jpeg';

  /// Fetches the floor plan image URL from the API.
  /// Returns the image URL string if successful, otherwise returns null.
  static Future<String?> getFloorPlanImageUrl() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        // Decode the JSON response body
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Check for 'success' status from the JSON body
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'] as Map<String, dynamic>?;

          // Safely extract the 'plan' field from the 'data' object
          if (data != null && data.containsKey('plan')) {
            final imageUrl = data['plan'] as String?;
            return imageUrl;
          } else {
            print("API response success=true but 'data' or 'plan' field is missing.");
            return null;
          }
        } else {
          print("API reported success: false. Response: ${jsonResponse['message']}");
          return null;
        }
      } else {
        // Handle non-200 status codes (e.g., 404, 500)
        print("Failed to load floor plan data. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      // Handle network errors or decoding errors
      print("Error fetching floor plan image URL: $e");
      return null;
    }
  }
}