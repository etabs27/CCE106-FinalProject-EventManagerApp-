import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _eventsCollection = _firestore.collection('events');
  static final CollectionReference _usersCollection = _firestore.collection('users');

  // Get total events count
  static Stream<int> getTotalEvents() {
    return _eventsCollection.snapshots().map((snapshot) => snapshot.docs.length);
  }

  // Get pending approvals count
  static Stream<int> getPendingApprovals() {
    return _eventsCollection
        .where('status', isEqualTo: 0) // 0 = pending
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get active managers count (users with role 'manager')
  static Stream<int> getActiveManagers() {
    return _usersCollection
        .where('role', isEqualTo: 'manager')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get total users count
  static Stream<int> getTotalUsers() {
    return _usersCollection.snapshots().map((snapshot) => snapshot.docs.length);
  }

  // Get recent activity from events
  static Stream<List<Map<String, dynamic>>> getRecentActivity() {
    return _eventsCollection
        .snapshots()
        .map((snapshot) {
          final activities = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'title': data['title'] ?? 'No Title',
              'action': _getActionText(data),
              'time': data['reviewedAt'] ?? data['submittedAt'],
              'icon': _getActionIcon(data),
            };
          }).toList();

          // Sort by reviewedAt or submittedAt descending in memory to avoid index requirement
          activities.sort((a, b) {
            final timeA = a['time'] as Timestamp?;
            final timeB = b['time'] as Timestamp?;
            if (timeA == null && timeB == null) return 0;
            if (timeA == null) return 1;
            if (timeB == null) return -1;
            return timeB.compareTo(timeA);
          });

          // Take only the most recent 5 activities
          return activities.take(5).toList();
        });
  }

  // Helper to get action text
  static String _getActionText(Map<String, dynamic> data) {
    final status = data['status'] as int?;
    final title = data['title'] ?? 'Event';
    
    if (status == 1) {
      return 'Event "$title" approved';
    } else if (status == 2) {
      return 'Event "$title" rejected';
    } else if (status == 0) {
      return 'New event created: "$title"';
    } else {
      return 'Event "$title" updated';
    }
  }

  // Helper to get action icon
  static String _getActionIcon(Map<String, dynamic> data) {
    final status = data['status'] as int?;
    
    if (status == 1) return 'check_circle';
    if (status == 2) return 'cancel';
    if (status == 0) return 'event_available';
    return 'update';
  }

  // Get all dashboard stats at once
  static Stream<Map<String, dynamic>> getDashboardStats() {
    return _eventsCollection.snapshots().asyncMap((eventSnapshot) async {
      // Get user counts
      final userSnapshot = await _usersCollection.get();
      final managerSnapshot = await _usersCollection.where('role', isEqualTo: 'manager').get();
      final pendingSnapshot = await _eventsCollection.where('status', isEqualTo: 0).get();
      
      return {
        'totalEvents': eventSnapshot.docs.length,
        'pendingApprovals': pendingSnapshot.docs.length,
        'activeManagers': managerSnapshot.docs.length,
        'totalUsers': userSnapshot.docs.length,
      };
    });
  }
}