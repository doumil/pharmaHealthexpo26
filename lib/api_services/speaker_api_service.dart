// lib/api_services/speaker_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/speakers_model.dart'; // Import the model

class SpeakerApiService {
  // 🚀 NEW API URL for speakers with sessions
  final String baseUrl = "https://buzzevents.co/api/edition/1118/speakers-with-sessions";

  // 📸 Base URL for speaker images
  static const String imageBaseUrl = "https://buzzevents.co/uploads/";

  Future<SpeakersDataModel> fetchSpeakersWithSessions() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

      // Pass the entire response map to the model's factory for full parsing
      // which now handles the 'data', 'periods', and 'speakers' structure.
      return SpeakersDataModel.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load speakers data. Status Code: ${response.statusCode}');
    }
  }
}