// lib/model/event_contact_model.dart

import 'organizer_model.dart';

class EventContactModel {
  final String eventName;
  final String description;
  final String logoName;
  final OrganizerModel organizer;
  final String scheduledStartDate;
  final String scheduledEndDate;

  EventContactModel({
    required this.eventName,
    required this.description,
    required this.logoName,
    required this.organizer,
    required this.scheduledStartDate,
    required this.scheduledEndDate,
  });

  factory EventContactModel.fromJson(Map<String, dynamic> json) {
    // Safely get data[0] (main event) and cast it to Map<String, dynamic>
    final Map<String, dynamic> eventData = json['data'] is List && json['data'].isNotEmpty
        ? (json['data'][0] as Map<String, dynamic>? ?? {})
        : {};

    // Safely get the organizer and cast it to Map<String, dynamic>
    final Map<String, dynamic> organizerData = eventData['organizer'] is Map
        ? (eventData['organizer'] as Map<String, dynamic>? ?? {})
        : {};

    // Delegate to the OrganizerModel.fromJson
    final organizer = OrganizerModel.fromJson(organizerData);

    return EventContactModel(
      eventName: eventData['name'] as String? ?? 'Pharma Health Expo',
      description: eventData['description'] as String? ?? 'Application mobile pour Pharma Health Expo',
      logoName: eventData['logo_name'] as String? ?? eventData['logo'] as String? ?? 'default-logo.png',
      organizer: organizer,
      // 🛠️ قراءة التواريخ مباشرة بالشكل الصحيح الذي أرسلناه من Service
      scheduledStartDate: eventData['scheduled_start_date'] as String? ?? '',
      scheduledEndDate: eventData['scheduled_end_date'] as String? ?? '',
    );
  }
}