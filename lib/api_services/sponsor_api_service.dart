// lib/api_services/sponsor_api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:emecexpo/model/sponsor_model.dart';

class SponsorApiService {
  static const String _sponsorUrl = 'https://buzzevents.co/api/sponosors';

  Future<List<SponsorClass>> getSponsors() async {
    debugPrint("🔍 Attempting to fetch sponsors from API: $_sponsorUrl");
    try {
      final response = await http.get(Uri.parse(_sponsorUrl));

      if (response.statusCode == 200) {
        debugPrint("✅ Sponsors API request successful (Status 200).");
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          List<dynamic> dataList = jsonData['data'];
          return dataList.map((json) => SponsorClass.fromJson(json)).toList();
        } else {
          debugPrint("⚠️ Sponsors API response is missing the 'data' key or data is not a list.");
          throw const FormatException("API response is missing the 'data' key or data is not a list.");
        }
      } else {
        debugPrint("⚠️ Sponsors API request failed with status code: ${response.statusCode}");
        throw HttpException('Failed to load sponsors data. Status Code: ${response.statusCode}');
      }
    } on SocketException {
      debugPrint("❌ Network error: Could not connect to sponsors host.");
      throw const SocketException('No Internet connection to fetch sponsors.');
    } catch (e) {
      debugPrint("❌ An unexpected error occurred while fetching sponsors: $e");
      rethrow;
    }
  }
}