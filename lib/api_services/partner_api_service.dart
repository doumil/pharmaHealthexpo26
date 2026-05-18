// lib/api_services/partner_api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pharma_health_expo/model/partner_model.dart';

class PartnerApiService {
  static const String _partnerUrl = 'https://buzzevents.co/api/partner';

  Future<List<PartnerClass>> getPartners() async {
    debugPrint("🔍 Attempting to fetch partners from API: $_partnerUrl");
    try {
      final response = await http.get(Uri.parse(_partnerUrl));

      if (response.statusCode == 200) {
        debugPrint("✅ Partners API request successful (Status 200).");
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          List<dynamic> dataList = jsonData['data'];
          // The API structure from your old code suggests image1 and image2 might be nested.
          // This model assumes a flat structure where each list item is a single partner.
          return dataList.map((json) => PartnerClass.fromJson(json)).toList();
        } else {
          debugPrint("⚠️ Partners API response is missing the 'data' key or data is not a list.");
          return []; // Return empty list on structure mismatch
        }
      } else {
        debugPrint("⚠️ Partners API request failed with status code: ${response.statusCode}");
        throw HttpException('Failed to load partners data. Status Code: ${response.statusCode}');
      }
    } on SocketException {
      debugPrint("❌ Network error: Could not connect to partners host.");
      // Fail silently and let the UI show an empty/error state
      return [];
    } catch (e) {
      debugPrint("❌ An unexpected error occurred while fetching partners: $e");
      rethrow;
    }
  }
}