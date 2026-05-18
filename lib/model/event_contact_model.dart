// lib/model/event_contact_model.dart

import 'organizer_model.dart';

class EventContactModel {
  final String eventName;
  final String description;
  final String logoName;
  final OrganizerModel organizer; // Now uses the updated OrganizerModel
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

    // Safely get data[1] (schedule) and cast it to Map<String, dynamic>
    final Map<String, dynamic> scheduleData = json['data'] is List && json['data'].length > 1
        ? (json['data'][1] as Map<String, dynamic>? ?? {})
        : {};

    // Safely get the first organizer and cast it to Map<String, dynamic>
    final Map<String, dynamic> organizerData = eventData['organisateurs'] is List && eventData['organisateurs'].isNotEmpty
        ? (eventData['organisateurs'][0] as Map<String, dynamic>? ?? {})
        : {};

    // Delegate to the new OrganizerModel.fromJson
    final organizer = OrganizerModel.fromJson(organizerData);

    // Safely access nested schedule data and cast to Map<String, dynamic>
    final Map<String, dynamic> start = scheduleData['start'] is Map
        ? (scheduleData['start'] as Map<String, dynamic>? ?? {})
        : {};
    final Map<String, dynamic> end = scheduleData['end'] is Map
        ? (scheduleData['end'] as Map<String, dynamic>? ?? {})
        : {};

    return EventContactModel(
      eventName: eventData['name'] as String? ?? 'N/A Event Name',
      description: eventData['description'] as String? ?? 'No description available.',
      logoName: eventData['logo'] as String? ?? 'default-logo.png',
      organizer: organizer,
      scheduledStartDate: start['date'] as String? ?? '2000-01-01 00:00:00.000000',
      scheduledEndDate: end['date'] as String? ?? '2000-01-01 00:00:00.000000',
    );
  }
}