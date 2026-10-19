// lib/api_services/event_contact_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pharma_health_expo/global/app_config.dart';
import '../model/event_contact_model.dart';

class EventContactApiService {
  static final String _eventUrl = AppConfig.eventActiveEditionUrl;
  static final String _settingsUrl = AppConfig.appSettingsUrl;

  Future<EventContactModel> fetchEventDetails() async {
    try {
      print('DEBUG: [EventContactApiService] Fetching from both APIs parallelly...');

      final responses = await Future.wait([
        http.get(Uri.parse(_eventUrl)),
        http.get(Uri.parse(_settingsUrl)),
      ]);

      final eventResponse = responses[0];
      final settingsResponse = responses[1];

      if (eventResponse.statusCode == 200) {
        final Map<String, dynamic> activeEditionJson = json.decode(eventResponse.body) as Map<String, dynamic>;

        if (activeEditionJson['success'] == true && activeEditionJson['data'] != null) {
          final Map<String, dynamic> editionData = Map<String, dynamic>.from(activeEditionJson['data']);

          // 🛑 قراءة التواريخ كما هي من الـ API (بدون أي قيم افتراضية)
          var rawStart = editionData['date_debut'];
          var rawEnd = editionData['date_fin'];

          print('DEBUG ---> Raw API date_debut: $rawStart');
          print('DEBUG ---> Raw API date_fin: $rawEnd');

          // التحويل فقط إيلا كانت القيمة موجودة، وإلا تخليها كيف ما هي (null أو فارغة)
          String formattedStart = rawStart != null ? _convertApiDateToIso(rawStart.toString()) : '';
          String formattedEnd = rawEnd != null ? _convertApiDateToIso(rawEnd.toString()) : '';

          // جلب الإيميل والهاتف من إعدادات التطبيق
          String phone = "";
          String email = "";

          if (settingsResponse.statusCode == 200) {
            final Map<String, dynamic> settingsJson = json.decode(settingsResponse.body) as Map<String, dynamic>;
            if (settingsJson['data'] != null) {
              final settingsData = settingsJson['data'];
              if (settingsData['support_phone'] != null) {
                phone = settingsData['support_phone']['value']?.toString() ?? "";
              }
              if (settingsData['contact_email'] != null) {
                email = settingsData['contact_email']['value']?.toString() ?? "";
              }
            }
          }

          // بناء هيكل JSON متوافق مع المودل الأصلي
          final Map<String, dynamic> normalizedJson = {
            'success': true,
            'data': [
              {
                'id': editionData['id'],
                'scheduled_start_date': formattedStart,
                'scheduled_end_date': formattedEnd,
                'logo_name': editionData['logo'] ?? '',
                'organizer': {
                  'phone': phone,
                  'email': email,
                },
                'venue': editionData['place'] != null ? {
                  'name': editionData['place']['name'] ?? '',
                  'address': editionData['place']['adresse'] ?? '',
                } : null,
              }
            ]
          };

          return EventContactModel.fromJson(normalizedJson);
        } else {
          throw Exception('Event data is missing from API.');
        }
      } else {
        throw Exception('Failed to load event details. Status Code: ${eventResponse.statusCode}');
      }
    } catch (e) {
      print('DEBUG: [EventContactApiService] Error: $e');
      throw Exception('Network or parsing error: $e');
    }
  }

  /// ⚙️ دالة تحويل التاريخ
  String _convertApiDateToIso(String dateStr) {
    if (dateStr.trim().isEmpty || dateStr.toLowerCase() == 'null') return '';
    try {
      if (dateStr.contains('-') && dateStr.length >= 10) {
        return dateStr.substring(0, 10);
      }

      if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          final month = parts[0].padLeft(2, '0');
          final day = parts[1].padLeft(2, '0');
          final year = parts[2];
          return '$year-$month-$day';
        }
      }
    } catch (e) {
      print('DEBUG: Date conversion error for "$dateStr": $e');
    }
    return dateStr;
  }
}