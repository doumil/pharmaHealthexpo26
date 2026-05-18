// lib/model/agenda_model.dart

// This file now serves as the consolidated "Agenda Model".
// It contains the CongressDClass definition, which was previously in 'congress_model_detail.dart'.

import 'dart:convert';

class CongressDClass {
  String? id;
  String? title;
  String? discription;
  String? datetimeStart;
  String? datetimeEnd;
  String? speaker;
  String? location;
  List<String>? tags;

  CongressDClass({
    this.id,
    this.title,
    this.discription,
    this.datetimeStart,
    this.datetimeEnd,
    this.speaker,
    this.location,
    this.tags,
  });

  factory CongressDClass.fromJson(Map<String, dynamic> json) {
    return CongressDClass(
      id: json['id']?.toString(),
      title: json['title'] as String?,
      discription: json['discription'] as String?,
      datetimeStart: json['datetimeStart'] as String?,
      datetimeEnd: json['datetimeEnd'] as String?,
      speaker: json['speaker'] as String?,
      location: json['location'] as String?,
      tags: (json['tags'] is String && (json['tags'] as String).isNotEmpty)
          ? (json['tags'] as String).split(',').map((e) => e.trim()).toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'discription': discription,
      'datetimeStart': datetimeStart,
      'datetimeEnd': datetimeEnd,
      'speaker': speaker,
      'location': location,
      'tags': tags?.join(','),
    };
  }

  static CongressDClass fromJsonString(String str) => CongressDClass.fromJson(json.decode(str));

  String toJsonString() => json.encode(toMap());
}