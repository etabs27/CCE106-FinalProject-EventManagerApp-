import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _usersCollection = _firestore.collection('users');

  // Get total users count
  static Stream<int> getTotalUsersCount() {
    return _usersCollection.snapshots().map((snapshot) => snapshot.docs.length);
  }

  // Get managers count
  static Stream<int> getManagersCount() {
    return _usersCollection
        .snapshots()
        .map((snapshot) {
          final count = snapshot.docs
              .where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return (data['role'] as String?) == 'manager';
              })
              .length;
          return count;
        });
  }

  // Get admins count
  static Stream<int> getAdminsCount() {
    return _usersCollection
        .snapshots()
        .map((snapshot) {
          final count = snapshot.docs
              .where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return (data['role'] as String?) == 'admin';
              })
              .length;
          return count;
        });
  }

  // Get all managers
static Stream<List<Map<String, dynamic>>> getAllManagers() {
  return _usersCollection
      .where('role', isEqualTo: 'manager')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'] ?? 'No Name',
            'email': data['email'] ?? '',
            'isRestricted': data['isRestricted'] ?? false,
            'createdAt': data['createdAt'],
          };
        }).toList();
      })
      .handleError((error) {
        print('ERROR in getAllManagers: $error');
        return Stream.value([]);
      });
}

// Update manager name
static Future<void> updateManagerName(String email, String newName) async {
  try {
    final query = await _usersCollection.where('email', isEqualTo: email).get();
    if (query.docs.isNotEmpty) {
      await _usersCollection.doc(query.docs.first.id).update({
        'name': newName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  } catch (e) {
    print('ERROR updating manager name: $e');
    throw Exception('Failed to update manager');
  }
}

// Toggle manager restriction
static Future<void> toggleManagerRestriction(String email, bool isRestricted) async {
  try {
    final query = await _usersCollection.where('email', isEqualTo: email).get();
    if (query.docs.isNotEmpty) {
      await _usersCollection.doc(query.docs.first.id).update({
        'isRestricted': isRestricted,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  } catch (e) {
    print('ERROR toggling manager restriction: $e');
    throw Exception('Failed to update manager restriction');
  }
}
  // Get all users
  static Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _usersCollection
        .snapshots()
        .map((snapshot) {
          final allUsers = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'name': data['name'] ?? 'No Name',
              'email': data['email'] ?? 'No Email',
              'role': data['role'] ?? 'user',
              'createdAt': data['createdAt'],
              'lastActive': data['lastActive'],
              'isSuspended': data['isSuspended'] ?? false,
            };
          }).toList();

          // Debug: Log all users and their roles
          print('DEBUG: All users in database:');
          for (var user in allUsers) {
            print('  - ${user['email']}: role=${user['role']}');
          }

          final users = allUsers
              .where((user) => (user['role'] as String?) == 'user')
              .toList();

          print('DEBUG: Filtered users (role=user): ${users.length}');

          // Sort by name
          users.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

          return users;
        });
  }
  // Add to your existing UserService class:

// Update user suspension status
static Future<void> updateUserSuspension(String userId, bool shouldSuspend) async {
  try {
    await _usersCollection.doc(userId).update({
      'isSuspended': shouldSuspend,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    print('ERROR updating user suspension: $e');
    throw Exception('Failed to update user suspension');
  }
}

// Update user role
static Future<void> updateUserRole(String userId, String role) async {
  try {
    await _usersCollection.doc(userId).update({
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    print('ERROR updating user role: $e');
    throw Exception('Failed to update user role');
  }
}

// Delete user
static Future<void> deleteUser(String userId) async {
  try {
    await _usersCollection.doc(userId).delete();
  } catch (e) {
    print('ERROR deleting user: $e');
    throw Exception('Failed to delete user');
  }
}
}