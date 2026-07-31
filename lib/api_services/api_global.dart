// lib/api_services/api_global.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pharma_health_expo/global/app_config.dart';

class ApiGlobal {
  // دالة كتجيب لنا editionId الديناميكي من الـ API
  static Future<String> fetchActiveEditionId() async {
    final String url = '${AppConfig.baseUrl}/api/event/${AppConfig.eventId}/edition_active';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          // استخراج الـ id من داخل object ديال data
          final editionId = jsonResponse['data']['id'];
          return editionId.toString(); // نرجعوه كـ String
        } else {
          throw Exception('Failed to parse edition_active data.');
        }
      } else {
        throw Exception('Failed to load active edition. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: [ApiGlobal] Error fetching editionId: $e');
      // في حال وقع شي إيرور في الشبكة، كنحطو قيمة افتراضية (مثلاً القديمة باش التطبيق ما يطيحش)
      return "1150";
    }
  }
}