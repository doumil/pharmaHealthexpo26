// lib/services/google_calendar_service.dart

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/program_model.dart';

class GoogleCalendarService {
  /// Method to create an event in the user's phone calendar (Google, Apple, etc.)
  Future<void> createCalendarEvent(BuildContext context, ProgramItemModel item) async {

    // Parse the date strings into DateTime objects
    DateTime startDate;
    DateTime endDate;
    try {
      final inputFormat = DateFormat('MM/dd/yyyy h:mm a');
      startDate = inputFormat.parse(item.dateDeb);
      endDate = inputFormat.parse(item.dateFin);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Could not parse event dates.')),
      );
      return;
    }

    final event = Event(
      title: item.title,
      description: item.description,
      location: item.location,
      startDate: startDate,
      endDate: endDate,
    );

    final result = await Add2Calendar.addEvent2Cal(event);

    if (result == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create calendar event. Check permissions.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event sent to your calendar app.')),
      );
    }
  }
}