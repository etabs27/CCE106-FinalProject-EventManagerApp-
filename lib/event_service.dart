import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/event.dart';

class EventService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _eventsCollection = _firestore.collection('events');

  // Submit a new event
  static Future<String> submitEvent(Event event) async {
    try {
      print('SUBMITTING EVENT: ${event.title}');
      print('  - Status: ${event.status.index} (${event.status})');
      print('  - Manager: ${event.managerEmail}');
      print('  - Submitted at: ${event.submittedAt}');
      
      final eventData = event.toFirestore();
      print('  - Event data to save:');
      eventData.forEach((key, value) {
        print('    $key: $value (${value.runtimeType})');
      });
      
      final docRef = await _eventsCollection.add(eventData);
      print('Event submitted successfully! Document ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('ERROR submitting event: $e');
      throw Exception('Failed to submit event: $e');
    }
  }

  // Get all pending events for admin approval
  static Stream<List<Event>> getPendingEvents() {
    print('FETCHING PENDING EVENTS...');
    print('  - Query: status == ${EventStatus.pending.index} (${EventStatus.pending})');

    // First get all events, then filter and sort in memory to avoid index requirement
    return _eventsCollection
        .snapshots()
        .map((snapshot) {
          final allEvents = snapshot.docs
              .map((doc) => Event.fromFirestore(doc))
              .where((event) => event.status == EventStatus.pending)
              .toList();

          // Sort by submittedAt descending
          allEvents.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

          print(' Found ${allEvents.length} pending events');
          return allEvents;
        })
        .handleError((error) {
          print('ERROR in getPendingEvents stream: $error');
          throw error;
        });
  }

  // Get events by manager
  static Stream<List<Event>> getEventsByManager(String managerEmail) {
    print('FETCHING EVENTS FOR MANAGER: $managerEmail');

    return _eventsCollection
        .snapshots()
        .handleError((error) {
          print('ERROR in getEventsByManager stream: $error');
          if (error.toString().contains('index')) {
            print('INDEX ERROR: Create composite index for:');
            print('    - managerEmail (Ascending)');
            print('    - submittedAt (Descending)');
            print('    - __name__ (Ascending)');
          }
          throw error;
        })
        .map((snapshot) {
          print('Manager events snapshot: ${snapshot.docs.length} docs');

          final events = snapshot.docs
              .map((doc) => Event.fromFirestore(doc))
              .where((event) => event.managerEmail == managerEmail)
              .toList();

          // Sort by submittedAt descending in memory to avoid index requirement
          events.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

          // Log status distribution
          final pendingCount = events.where((e) => e.status == EventStatus.pending).length;
          final approvedCount = events.where((e) => e.status == EventStatus.approved).length;
          final rejectedCount = events.where((e) => e.status == EventStatus.rejected).length;
          final cancelledCount = events.where((e) => e.status == EventStatus.cancelled).length;

          print('Status distribution:');
          print('  - Pending: $pendingCount');
          print('  - Approved: $approvedCount');
          print('  - Rejected: $rejectedCount');
          print('  - Cancelled: $cancelledCount');

          return events;
        });
  }

  // Approve an event
  static Future<void> approveEvent(String eventId, String adminEmail) async {
    try {
      print('APPROVING EVENT: $eventId');
      print('  - Admin: $adminEmail');
      
      await _eventsCollection.doc(eventId).update({
        'status': EventStatus.approved.index,
        'reviewedAt': Timestamp.now(),
        'reviewedBy': adminEmail,
      });
      
      print('Event $eventId approved successfully!');
    } catch (e) {
      print('ERROR approving event $eventId: $e');
      throw Exception('Failed to approve event: $e');
    }
  }

  // Reject an event
  static Future<void> rejectEvent(String eventId, String adminEmail) async {
    try {
      print('REJECTING EVENT: $eventId');
      print('  - Admin: $adminEmail');
      
      await _eventsCollection.doc(eventId).update({
        'status': EventStatus.rejected.index,
        'reviewedAt': Timestamp.now(),
        'reviewedBy': adminEmail,
      });
      
      print('Event $eventId rejected successfully!');
    } catch (e) {
      print('ERROR rejecting event $eventId: $e');
      throw Exception('Failed to reject event: $e');
    }
  }

  // Get all approved events
  static Stream<List<Event>> getApprovedEvents() {
    print(' FETCHING APPROVED EVENTS...');

    return _eventsCollection
        .snapshots()
        .handleError((error) {
          print('ERROR in getApprovedEvents stream: $error');
          if (error.toString().contains('index')) {
            print('INDEX ERROR: Create composite index for:');
            print('    - status (Ascending)');
            print('    - date (Ascending)');
            print('    - __name__ (Ascending)');
          }
          throw error;
        })
        .map((snapshot) {
          print('Approved events snapshot: ${snapshot.docs.length} docs');
          final events = snapshot.docs
              .map((doc) => Event.fromFirestore(doc))
              .where((event) => event.status == EventStatus.approved)
              .toList();

          // Sort by date ascending in memory to avoid index requirement
          events.sort((a, b) => a.date.compareTo(b.date));

          return events;
        });
  }

  // Get event by ID
  static Future<Event?> getEventById(String eventId) async {
    try {
      print('GETTING EVENT BY ID: $eventId');
      
      final doc = await _eventsCollection.doc(eventId).get();
      
      if (doc.exists) {
        print('Found event: ${doc.id}');
        final data = doc.data() as Map<String, dynamic>;
        print('  - Title: ${data['title']}');
        print('  - Status: ${data['status']}');
        return Event.fromFirestore(doc);
      } else {
        print('Event not found: $eventId');
        return null;
      }
    } catch (e) {
      print('ERROR getting event $eventId: $e');
      throw Exception('Failed to get event: $e');
    }
  }

  // Get cancelled events by manager (optional - for dashboard filter)
  static Stream<List<Event>> getCancelledEventsByManager(String managerEmail) {
    print('FETCHING CANCELLED EVENTS FOR MANAGER: $managerEmail');

    return _eventsCollection
        .snapshots()
        .handleError((error) {
          print('ERROR in getCancelledEventsByManager: $error');
          throw error;
        })
        .map((snapshot) {
          print('Cancelled events: ${snapshot.docs.length}');
          final events = snapshot.docs
              .map((doc) => Event.fromFirestore(doc))
              .where((event) => event.managerEmail == managerEmail && event.status == EventStatus.cancelled)
              .toList();

          // Sort by submittedAt descending in memory to avoid index requirement
          events.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

          return events;
        });
  }

  // Debug helper: Check all events in collection
  static Future<void> debugAllEvents() async {
    try {
      print('=== DEBUG: ALL EVENTS IN COLLECTION ===');
      final snapshot = await _eventsCollection.limit(20).get();
      
      print('Total documents: ${snapshot.docs.length}');
      print('Status distribution:');
      
      final statusCount = <int, int>{};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as int? ?? -1;
        statusCount[status] = (statusCount[status] ?? 0) + 1;
      }
      
      statusCount.forEach((status, count) {
        print('  Status $status: $count events');
      });
      
      print('Sample events:');
      for (var i = 0; i < snapshot.docs.length && i < 5; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data() as Map<String, dynamic>;
        print('  ${i + 1}. ${data['title'] ?? 'No title'}');
        print('     - ID: ${doc.id}');
        print('     - Status: ${data['status']}');
        print('     - Manager: ${data['managerEmail']}');
        print('     - Submitted: ${data['submittedAt']}');
      }
      
      print('=== END DEBUG ===');
    } catch (e) {
      print('ERROR in debugAllEvents: $e');
    }
  }

  // Test query for pending events (for admin debugging)
  static Future<void> testPendingQuery() async {
    try {
      print('=== TESTING PENDING EVENTS QUERY ===');
      
      final snapshot = await _eventsCollection
          .where('status', isEqualTo: EventStatus.pending.index)
          .limit(10)
          .get();
      
      print('Found ${snapshot.docs.length} pending events:');
      
      if (snapshot.docs.isEmpty) {
        print('No pending events found. Checking all events...');
        final allSnapshot = await _eventsCollection.limit(10).get();
        print('Total events in collection: ${allSnapshot.docs.length}');
        
        for (var doc in allSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          print('  - ${data['title'] ?? 'No title'}: status=${data['status']}, manager=${data['managerEmail']}');
        }
      } else {
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          print('  - ${data['title'] ?? 'No title'}');
          print('    Manager: ${data['managerEmail']}');
          print('    Submitted: ${data['submittedAt']}');
        }
      }
      
      print('=== END TEST ===');
    } catch (e) {
      print('TEST FAILED: $e');
      if (e.toString().contains('index')) {
        print('Create this composite index in Firebase Console:');
        print('    Collection: events');
        print('    Fields:');
        print('      1. status (Ascending)');
        print('      2. submittedAt (Descending)');
        print('      3. __name__ (Ascending)');
      }
    }
  }

  // Check if there are any pending events at all
  static Future<bool> hasPendingEvents() async {
    try {
      print(' CHECKING FOR ANY PENDING EVENTS...');
      final snapshot = await _eventsCollection
          .where('status', isEqualTo: EventStatus.pending.index)
          .limit(1)
          .get();
      
      final hasEvents = snapshot.docs.isNotEmpty;
      print(hasEvents ? ' Found pending events' : ' No pending events found');
      return hasEvents;
    } catch (e) {
      print('ERROR checking for pending events: $e');
      return false;
    }
  }

  // Manual count of all events by status
  static Future<Map<String, int>> getEventCounts() async {
    try {
      print(' GETTING EVENT COUNTS BY STATUS...');
      final snapshot = await _eventsCollection.get();
      
      final counts = {
        'pending': 0,
        'approved': 0,
        'rejected': 0,
        'cancelled': 0,
        'total': snapshot.docs.length,
      };
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as int?;
        
        switch (status) {
          case 0:
            counts['pending'] = counts['pending']! + 1;
            break;
          case 1:
            counts['approved'] = counts['approved']! + 1;
            break;
          case 2:
            counts['rejected'] = counts['rejected']! + 1;
            break;
          case 3:
            counts['cancelled'] = counts['cancelled']! + 1;
            break;
          default:
            print(' Unknown status value: $status in doc ${doc.id}');
        }
      }
      
      print('Event Counts:');
      counts.forEach((key, value) {
        print('  $key: $value');
      });
      
      return counts;
    } catch (e) {
      print('ERROR getting event counts: $e');
      return {
        'pending': 0,
        'approved': 0,
        'rejected': 0,
        'cancelled': 0,
        'total': 0,
      };
    }
  }

  // Temporary fix for admin pending query (bypass index requirement)
  static Stream<List<Event>> getPendingEventsTemporary() {
    print(' USING TEMPORARY PENDING QUERY (with limit)...');

    return _eventsCollection
        .snapshots()
        .map((snapshot) {
          print('Temporary pending query results: ${snapshot.docs.length}');
          final events = snapshot.docs
              .map((doc) => Event.fromFirestore(doc))
              .where((event) => event.status == EventStatus.pending)
              .toList();

          // Sort by submittedAt descending in memory to avoid index requirement
          events.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

          // Apply limit after sorting
          return events.take(50).toList();
        });
  }

  // Check actual data in events collection
  static Future<void> checkEventStatusValues() async {
    try {
      print(' CHECKING EVENT STATUS VALUES...');
      final snapshot = await _eventsCollection.limit(10).get();
      
      if (snapshot.docs.isEmpty) {
        print(' NO EVENTS IN COLLECTION AT ALL');
        return;
      }
      
      print('Found ${snapshot.docs.length} events:');
      for (var i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data() as Map<String, dynamic>;
        
        print('Event ${i + 1}:');
        print('  ID: ${doc.id}');
        print('  Title: ${data['title'] ?? "No title"}');
        print('  Status: ${data['status']} (type: ${data['status']?.runtimeType})');
        print('  Manager: ${data['managerEmail'] ?? "No manager"}');
        print('  Submitted: ${data['submittedAt']}');
        
        // Check if status is null
        if (data['status'] == null) {
          print(' WARNING: status field is NULL!');
        }
        
        // Check if status is 0 (pending)
        if (data['status'] == 0) {
          print('This is a pending event (status: 0)');
        }
      }
    } catch (e) {
      print('ERROR checking event status: $e');
    }
  }

  // Test if we can parse events
  static Future<void> testEventParsing() async {
    try {
      print('TESTING EVENT PARSING...');
      final snapshot = await _eventsCollection.limit(1).get();
      
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        print('Testing with document: ${doc.id}');
        print('Raw data: ${doc.data()}');
        
        try {
          final event = Event.fromFirestore(doc);
          print('Successfully parsed event:');
          print('  Title: ${event.title}');
          print('  Status: ${event.status} (index: ${event.status.index})');
          print('  Manager: ${event.managerEmail}');
          print('  Date: ${event.date}');
          print('  Has startTime: ${event.startTime != null}');
          print('  Has endTime: ${event.endTime != null}');
          print('  Has capacity: ${event.capacity != null}');
        } catch (e) {
          print('ERROR parsing event: $e');
          print('Stack trace:');
          print(e.toString());
        }
      } else {
        print('No documents to test parsing');
      }
    } catch (e) {
      print('ERROR in testEventParsing: $e');
    }
  }

  // Simple test without orderBy
  static Future<void> simpleTest() async {
    try {
      print('SIMPLE TEST: Get events with status = 0');
      final snapshot = await _eventsCollection
          .where('status', isEqualTo: 0)
          .get();
      
      print('Simple query found ${snapshot.docs.length} events');
      
      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          print('  - ${data['title']}: status=${data['status']}, manager=${data['managerEmail']}');
        }
      }
    } catch (e) {
      print('Simple test error: $e');
    }
  }

  static Stream<int> getTotalEventsCount() {
  return _eventsCollection.snapshots().map((snapshot) => snapshot.docs.length);
}

// Get pending events count
static Stream<int> getPendingEventsCount() {
  return _eventsCollection
      .snapshots()
      .map((snapshot) {
        final count = snapshot.docs
            .where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return (data['status'] as int?) == EventStatus.pending.index;
            })
            .length;
        return count;
      });
}

// Get approved events count
static Stream<int> getApprovedEventsCount() {
  return _eventsCollection
      .snapshots()
      .map((snapshot) {
        final count = snapshot.docs
            .where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return (data['status'] as int?) == EventStatus.approved.index;
            })
            .length;
        return count;
      });
}

// Get rejected events count
static Stream<int> getRejectedEventsCount() {
  return _eventsCollection
      .snapshots()
      .map((snapshot) {
        final count = snapshot.docs
            .where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return (data['status'] as int?) == EventStatus.rejected.index;
            })
            .length;
        return count;
      });
}

// Get cancelled events count
static Stream<int> getCancelledEventsCount() {
  return _eventsCollection
      .snapshots()
      .map((snapshot) {
        final count = snapshot.docs
            .where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return (data['status'] as int?) == EventStatus.cancelled.index;
            })
            .length;
        return count;
      });
}

  static Stream<List<Event>> getRecentEvents() {
    print('FETCHING RECENT EVENTS...');

    // Get recent events (last 10) sorted by submittedAt descending
    return _eventsCollection
        .snapshots()
        .map((snapshot) {
          final events = snapshot.docs
              .map((doc) => Event.fromFirestore(doc))
              .toList();

          // Sort by submittedAt descending in memory to avoid index requirement
          events.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

          // Take only the most recent 10
          final recentEvents = events.take(10).toList();

          print('Found ${recentEvents.length} recent events');
          return recentEvents;
        })
        .handleError((error) {
          print('ERROR in getRecentEvents stream: $error');
          throw error;
        });
  }

  // Get all events
  static Stream<List<Event>> getAllEvents() {
    print('FETCHING ALL EVENTS...');
    
    return _eventsCollection
        .snapshots()
        .map((snapshot) {
          final events = snapshot.docs
              .map((doc) => Event.fromFirestore(doc))
              .toList();
          
          // Sort by date ascending in memory to avoid index requirement
          events.sort((a, b) => a.date.compareTo(b.date));
          
          print('Found ${events.length} total events');
          return events;
        })
        .handleError((error) {
          print('ERROR in getAllEvents stream: $error');
          throw error;
        });
  }
  static Future<List<Event>> getEventsByManagerList(String managerEmail) async {
  try {
    final snapshot = await _eventsCollection
        .where('managerEmail', isEqualTo: managerEmail)
        .get();
    
    return snapshot.docs
        .map((doc) => Event.fromFirestore(doc))
        .toList();
  } catch (e) {
    print('ERROR getting events by manager list: $e');
    return [];
  }
}
// Add these methods to your EventService class

// Get total events count (already exists, but adding comment)
// static Stream<int> getTotalEventsCount() { ... }

// Get events count by manager for dashboard stats
static Stream<int> getEventsCountByManager(String managerEmail) {
  print('GETTING EVENT COUNT FOR MANAGER: $managerEmail');
  
  return _eventsCollection.snapshots().map((snapshot) {
    final count = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return (data['managerEmail'] as String?) == managerEmail;
    }).length;
    
    print('Manager $managerEmail has $count events');
    return count;
  });
}

// Get pending events count (already exists)
// static Stream<int> getPendingEventsCount() { ... }

// Get active events count (approved and in future)
static Stream<int> getActiveEventsCount() {
  return _eventsCollection.snapshots().map((snapshot) {
    final now = DateTime.now();
    final count = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] as int?;
      final date = (data['date'] as Timestamp?)?.toDate();
      
      return status == EventStatus.approved.index && 
             date != null && 
             date.isAfter(now);
    }).length;
    
    return count;
  });
}

// Get completed events count (approved and in past)
static Stream<int> getCompletedEventsCount() {
  return _eventsCollection.snapshots().map((snapshot) {
    final now = DateTime.now();
    final count = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] as int?;
      final date = (data['date'] as Timestamp?)?.toDate();
      
      return status == EventStatus.approved.index && 
             date != null && 
             date.isBefore(now);
    }).length;
    
    return count;
  });
}

// Get events statistics for dashboard
static Future<Map<String, dynamic>> getDashboardStats() async {
  try {
    print('FETCHING DASHBOARD STATS...');
    final snapshot = await _eventsCollection.get();
    
    final now = DateTime.now();
    int total = 0;
    int pending = 0;
    int active = 0;
    int completed = 0;
    int cancelled = 0;
    int rejected = 0;
    
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] as int?;
      final date = (data['date'] as Timestamp?)?.toDate();
      
      total++;
      
      switch (status) {
        case 0: // pending
          pending++;
          break;
        case 1: // approved
          if (date != null) {
            if (date.isAfter(now)) {
              active++;
            } else {
              completed++;
            }
          }
          break;
        case 2: // rejected
          rejected++;
          break;
        case 3: // cancelled
          cancelled++;
          break;
      }
    }
    
    final stats = {
      'totalEvents': total,
      'pendingApprovals': pending,
      'activeEvents': active,
      'completedEvents': completed,
      'cancelledEvents': cancelled,
      'rejectedEvents': rejected,
    };
    
    print('Dashboard Stats:');
    stats.forEach((key, value) {
      print('  $key: $value');
    });
    
    return stats;
  } catch (e) {
    print('ERROR getting dashboard stats: $e');
    return {
      'totalEvents': 0,
      'pendingApprovals': 0,
      'activeEvents': 0,
      'completedEvents': 0,
      'cancelledEvents': 0,
      'rejectedEvents': 0,
    };
  }
}

// Search events by query
static Stream<List<Event>> searchEvents(String query) {
  print('SEARCHING EVENTS FOR: $query');
  
  return _eventsCollection.snapshots().map((snapshot) {
    final lowercaseQuery = query.toLowerCase();
    
    final events = snapshot.docs
        .map((doc) => Event.fromFirestore(doc))
        .where((event) {
          // Search in title, description, category, manager email
          final title = event.title.toLowerCase();
          final description = event.description?.toLowerCase() ?? '';
          final category = event.category.toLowerCase();
          final managerEmail = event.managerEmail.toLowerCase();
          
          return title.contains(lowercaseQuery) ||
                 description.contains(lowercaseQuery) ||
                 category.contains(lowercaseQuery) ||
                 managerEmail.contains(lowercaseQuery);
        })
        .toList();
    
    // Sort by date ascending
    events.sort((a, b) => a.date.compareTo(b.date));
    
    print('Found ${events.length} events matching "$query"');
    return events;
  });
}
// Cancel an event
static Future<void> cancelEvent(String eventId, String reason) async {
  try {
    print('CANCELLING EVENT: $eventId');
    print('  - Reason: $reason');
    
    await _eventsCollection.doc(eventId).update({
      'status': EventStatus.cancelled.index,
      'cancelledAt': Timestamp.now(),
      'cancellationReason': reason,
    });
    
    print('Event $eventId cancelled successfully!');
  } catch (e) {
    print('ERROR cancelling event $eventId: $e');
    throw Exception('Failed to cancel event: $e');
  }
}

// Update event
static Future<void> updateEvent(String eventId, Map<String, dynamic> updates) async {
  try {
    print('UPDATING EVENT: $eventId');
    print('  - Updates: $updates');
    
    await _eventsCollection.doc(eventId).update({
      ...updates,
      'updatedAt': Timestamp.now(),
    });
    
    print('Event $eventId updated successfully!');
  } catch (e) {
    print('ERROR updating event $eventId: $e');
    throw Exception('Failed to update event: $e');
  }
}

// Delete event
static Future<void> deleteEvent(String eventId) async {
  try {
    print('DELETING EVENT: $eventId');
    
    await _eventsCollection.doc(eventId).delete();
    
    print('Event $eventId deleted successfully!');
  } catch (e) {
    print('ERROR deleting event $eventId: $e');
    throw Exception('Failed to delete event: $e');
  }
}

// Get upcoming events (approved and in future)
static Stream<List<Event>> getUpcomingEvents({int limit = 10}) {
  print('FETCHING UPCOMING EVENTS...');
  
  return _eventsCollection.snapshots().map((snapshot) {
    final now = DateTime.now();
    
    final events = snapshot.docs
        .map((doc) => Event.fromFirestore(doc))
        .where((event) => 
          event.status == EventStatus.approved && 
          event.date.isAfter(now))
        .toList();
    
    // Sort by date ascending
    events.sort((a, b) => a.date.compareTo(b.date));
    
    // Take limited number
    final limitedEvents = events.take(limit).toList();
    
    print('Found ${limitedEvents.length} upcoming events');
    return limitedEvents;
  });
}

// Get events by date range
static Stream<List<Event>> getEventsByDateRange(DateTime startDate, DateTime endDate) {
  print('FETCHING EVENTS FROM ${startDate.toIso8601String()} TO ${endDate.toIso8601String()}');
  
  return _eventsCollection.snapshots().map((snapshot) {
    final events = snapshot.docs
        .map((doc) => Event.fromFirestore(doc))
        .where((event) => 
          event.date.isAfter(startDate) && 
          event.date.isBefore(endDate))
        .toList();
    
    // Sort by date ascending
    events.sort((a, b) => a.date.compareTo(b.date));
    
    print('Found ${events.length} events in date range');
    return events;
  });
}

// Get events by status
static Stream<List<Event>> getEventsByStatus(EventStatus status) {
  print('FETCHING EVENTS WITH STATUS: $status');
  
  return _eventsCollection.snapshots().map((snapshot) {
    final events = snapshot.docs
        .map((doc) => Event.fromFirestore(doc))
        .where((event) => event.status == status)
        .toList();
    
    // Sort by submittedAt descending for pending, date ascending for others
    if (status == EventStatus.pending) {
      events.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    } else {
      events.sort((a, b) => a.date.compareTo(b.date));
    }
    
    print('Found ${events.length} events with status $status');
    return events;
  });
}

// Get events by category
static Stream<List<Event>> getEventsByCategory(String category) {
  print('🏷️ FETCHING EVENTS WITH CATEGORY: $category');
  
  return _eventsCollection.snapshots().map((snapshot) {
    final events = snapshot.docs
        .map((doc) => Event.fromFirestore(doc))
        .where((event) => event.category.toLowerCase() == category.toLowerCase())
        .toList();
    
    // Sort by date ascending
    events.sort((a, b) => a.date.compareTo(b.date));
    
    print('Found ${events.length} events in category $category');
    return events;
  });
}

// Get all event categories
static Future<List<String>> getAllEventCategories() async {
  try {
    print('FETCHING ALL EVENT CATEGORIES...');
    final snapshot = await _eventsCollection.get();
    
    final categories = <String>{};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final category = data['category'] as String?;
      if (category != null && category.isNotEmpty) {
        categories.add(category);
      }
    }
    
    final sortedCategories = categories.toList()..sort();
    print('Found ${sortedCategories.length} unique categories');
    return sortedCategories;
  } catch (e) {
    print('ERROR getting event categories: $e');
    return [];
  }
}

static Future<void> registerUserForEvent(String eventId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('User not authenticated');
  
  await FirebaseFirestore.instance.collection('events').doc(eventId).update({
    'registeredAttendees': FieldValue.increment(1),
  });
}
}