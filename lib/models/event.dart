import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum EventStatus { pending, approved, rejected, cancelled }

class Event {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String venue;
  final String fullAddress;
  final int capacity;
  final double? price;
  final String managerEmail;
  final String? imageUrl;
  final EventStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final int? registeredAttendees;
  final int? checkedInAttendees;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.venue,
    required this.fullAddress,
    required this.capacity,
    this.price,
    required this.managerEmail,
    this.imageUrl,
    this.status = EventStatus.pending,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.registeredAttendees,
    this.checkedInAttendees,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final statusIndex = (data['status'] as int?) ?? 0;
    final status = statusIndex < EventStatus.values.length 
        ? EventStatus.values[statusIndex]
        : EventStatus.pending;

    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: TimeOfDay(
        hour: data['startTime']['hour'] ?? 0,
        minute: data['startTime']['minute'] ?? 0,
      ),
      endTime: TimeOfDay(
        hour: data['endTime']['hour'] ?? 0,
        minute: data['endTime']['minute'] ?? 0,
      ),
      venue: data['venue'] ?? '',
      fullAddress: data['fullAddress'] ?? '',
      capacity: data['capacity'] ?? 0,
      price: data['price']?.toDouble(),
      managerEmail: data['managerEmail'] ?? '',
      imageUrl: data['imageUrl'],
      status: EventStatus.values[(data['status'] as int?) ?? 0],
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      reviewedAt: data['reviewedAt'] != null ? (data['reviewedAt'] as Timestamp).toDate() : null,
      reviewedBy: data['reviewedBy'],
      registeredAttendees: data['registeredAttendees'],
      checkedInAttendees: data['checkedInAttendees'],
    );
  }

  // ADDED: New factory constructor for querying approved events
  factory Event.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Check what type of status is stored (int or string)
    final statusValue = data['status'];
    EventStatus status;
    
    if (statusValue is String) {
      // If status is stored as string 'approved'
      status = statusValue == 'approved' ? EventStatus.approved : EventStatus.pending;
    } else if (statusValue is int) {
      // If status is stored as int (1 = approved)
      status = statusValue == 1 ? EventStatus.approved : EventStatus.pending;
    } else {
      status = EventStatus.pending;
    }
    
    // Parse date - check if date field exists
    DateTime eventDate;
    if (data.containsKey('date') && data['date'] is Timestamp) {
      eventDate = (data['date'] as Timestamp).toDate();
    } else {
      // If no date field, use current date with hour/minute
      final now = DateTime.now();
      final hour = data['hour'] as int? ?? 0;
      final minute = data['minute'] as int? ?? 0;
      eventDate = DateTime(now.year, now.month, now.day, hour, minute);
    }
    
    // Parse startTime
    TimeOfDay startTime;
    if (data.containsKey('startTime') && data['startTime'] is Map) {
      final startTimeData = data['startTime'] as Map<String, dynamic>;
      startTime = TimeOfDay(
        hour: startTimeData['hour'] as int? ?? 0,
        minute: startTimeData['minute'] as int? ?? 0,
      );
    } else {
      // Fallback to hour/minute fields
      startTime = TimeOfDay(
        hour: data['hour'] as int? ?? 0,
        minute: data['minute'] as int? ?? 0,
      );
    }
    
    // Parse endTime
    TimeOfDay? endTime;
    if (data.containsKey('endTime') && data['endTime'] is Map) {
      final endTimeData = data['endTime'] as Map<String, dynamic>;
      endTime = TimeOfDay(
        hour: endTimeData['hour'] as int? ?? 0,
        minute: endTimeData['minute'] as int? ?? 0,
      );
    }
    
    // Get venue - try fullAddress first, then venue
    final venue = data['fullAddress'] as String? ?? data['venue'] as String? ?? '';
    
    return Event(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled Event',
      description: data['description'] as String? ?? '',
      date: eventDate,
      startTime: startTime,
      endTime: endTime ?? TimeOfDay(hour: 23, minute: 59), // Default end time
      venue: venue,
      fullAddress: venue, // Use same as venue if fullAddress not available
      category: data['category'] as String? ?? 'General',
      capacity: data['capacity'] as int? ?? 0,
      registeredAttendees: data['registeredAttendees'] as int? ?? 0,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      managerEmail: data['managerEmail'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      status: status,
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reviewedAt: data['reviewedAt'] != null ? (data['reviewedAt'] as Timestamp).toDate() : null,
      reviewedBy: data['reviewedBy'] as String?,
      checkedInAttendees: data['checkedInAttendees'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'date': Timestamp.fromDate(date),
      'startTime': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'endTime': {
        'hour': endTime.hour,
        'minute': endTime.minute,
      },
      'venue': venue,
      'fullAddress': fullAddress,
      'capacity': capacity,
      'price': price,
      'managerEmail': managerEmail,
      'imageUrl': imageUrl,
      'status': status.index,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewedBy': reviewedBy,
      'registeredAttendees': registeredAttendees,
      'checkedInAttendees': checkedInAttendees,
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? venue,
    String? fullAddress,
    int? capacity,
    double? price,
    String? managerEmail,
    String? imageUrl,
    EventStatus? status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    int? registeredAttendees,
    int? checkedInAttendees,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      venue: venue ?? this.venue,
      fullAddress: fullAddress ?? this.fullAddress,
      capacity: capacity ?? this.capacity,
      price: price ?? this.price,
      managerEmail: managerEmail ?? this.managerEmail,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      registeredAttendees: registeredAttendees ?? this.registeredAttendees,
      checkedInAttendees: checkedInAttendees ?? this.checkedInAttendees,
    );
  }
}