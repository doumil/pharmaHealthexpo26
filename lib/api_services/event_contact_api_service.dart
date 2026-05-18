// lib/api_services/event_contact_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/event_contact_model.dart';

class EventContactApiService {
  static const String _apiUrl = 'https://buzzevents.co/api/event/189';

  /// Fetches event details and organizer contact from the API.
  Future<EventContactModel> fetchEventDetails() async {
    final url = Uri.parse(_apiUrl);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        if (jsonResponse['success'] == true && jsonResponse['data'] is List && jsonResponse['data'].isNotEmpty) {
          // The fromJson factory handles all complex parsing and model instantiation
          return EventContactModel.fromJson(jsonResponse);
        } else {
          throw Exception('API response succeeded but event data is missing or invalid.');
        }
      } else {
        throw Exception('Failed to load event details. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Re-throw the error for the calling widget (e.g., FutureBuilder)
      throw Exception('Network or parsing error: $e');
    }
  }
}