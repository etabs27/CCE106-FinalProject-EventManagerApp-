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
            
            // Extract name from new structure
            final firstName = data['firstName'] as String? ?? '';
            final lastName = data['lastName'] as String? ?? '';
            final middleName = data['middleName'] as String?;
            
            // Build full name
            String displayName = _buildFullName(firstName, lastName, middleName);
            if (displayName.isEmpty) {
              displayName = data['name'] as String? ?? 'No Name';
            }
            
            return {
              'id': doc.id,
              'name': displayName,
              'firstName': firstName,
              'lastName': lastName,
              'middleName': middleName,
              'fullName': displayName,
              'email': data['email'] ?? '',
              'isRestricted': data['isRestricted'] ?? false,
              'createdAt': data['createdAt'],
              'updatedAt': data['updatedAt'],
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

  // Get all users (UPDATED VERSION)
  static Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _usersCollection
        .snapshots()
        .map((snapshot) {
          final allUsers = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            
            // Extract name from new structure
            final firstName = data['firstName'] as String? ?? '';
            final lastName = data['lastName'] as String? ?? '';
            final middleName = data['middleName'] as String?;
            
            // Build full name
            String displayName = _buildFullName(firstName, lastName, middleName);
            if (displayName.isEmpty) {
              displayName = data['name'] as String? ?? 'No Name';
            }
            
            return {
              'id': doc.id,
              'name': displayName,
              'firstName': firstName,
              'lastName': lastName,
              'middleName': middleName,
              'fullName': displayName,
              'email': data['email'] ?? 'No Email',
              'role': data['role'] ?? 'user',
              'createdAt': data['createdAt'],
              'lastActive': data['lastActive'],
              'isSuspended': data['isSuspended'] ?? false,
              'updatedAt': data['updatedAt'],
            };
          }).toList();

          // Debug: Log all users and their roles
          print('DEBUG: All users in database:');
          for (var user in allUsers) {
            print('  - ${user['email']}: role=${user['role']}, name=${user['name']}');
          }

          // Return ALL users, not just role='user'
          final users = allUsers; // Removed the filter for role='user'

          print('DEBUG: Total users: ${users.length}');

          // Sort by name
          users.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

          return users;
        });
  }

  // Helper method to build full name
  static String _buildFullName(String firstName, String lastName, String? middleName) {
    if (firstName.isEmpty && lastName.isEmpty) return '';
    
    if (middleName != null && middleName.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }

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

  // Get user by ID
  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Extract name from new structure
        final firstName = data['firstName'] as String? ?? '';
        final lastName = data['lastName'] as String? ?? '';
        final middleName = data['middleName'] as String?;
        
        // Build full name
        String displayName = _buildFullName(firstName, lastName, middleName);
        if (displayName.isEmpty) {
          displayName = data['name'] as String? ?? 'No Name';
        }
        
        return {
          'id': doc.id,
          'name': displayName,
          'firstName': firstName,
          'lastName': lastName,
          'middleName': middleName,
          'fullName': displayName,
          'email': data['email'] ?? '',
          'role': data['role'] ?? 'user',
          'isSuspended': data['isSuspended'] ?? false,
          'createdAt': data['createdAt'],
          'lastActive': data['lastActive'],
          'updatedAt': data['updatedAt'],
        };
      }
      return null;
    } catch (e) {
      print('ERROR getting user by ID: $e');
      throw Exception('Failed to get user');
    }
  }

  // Get user by email
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final query = await _usersCollection.where('email', isEqualTo: email).limit(1).get();
      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        
        // Extract name from new structure
        final firstName = data['firstName'] as String? ?? '';
        final lastName = data['lastName'] as String? ?? '';
        final middleName = data['middleName'] as String?;
        
        // Build full name
        String displayName = _buildFullName(firstName, lastName, middleName);
        if (displayName.isEmpty) {
          displayName = data['name'] as String? ?? 'No Name';
        }
        
        return {
          'id': doc.id,
          'name': displayName,
          'firstName': firstName,
          'lastName': lastName,
          'middleName': middleName,
          'fullName': displayName,
          'email': data['email'] ?? '',
          'role': data['role'] ?? 'user',
          'isSuspended': data['isSuspended'] ?? false,
          'createdAt': data['createdAt'],
          'lastActive': data['lastActive'],
          'updatedAt': data['updatedAt'],
        };
      }
      return null;
    } catch (e) {
      print('ERROR getting user by email: $e');
      throw Exception('Failed to get user by email');
    }
  }

  // Update user profile
  static Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      await _usersCollection.doc(userId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('ERROR updating user profile: $e');
      throw Exception('Failed to update user profile');
    }
  }

  // Migrate existing users to new name structure
  static Future<void> migrateExistingUsers() async {
    try {
      print('Starting user migration...');
      final usersSnapshot = await _usersCollection.get();
      int migratedCount = 0;
      
      for (var doc in usersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Check if user has old 'name' field but no firstName/lastName
        if ((data['name'] != null) && 
            (data['firstName'] == null || data['lastName'] == null)) {
          
          final name = data['name'] as String;
          final parts = name.trim().split(' ');
          
          // Simple parsing - first part as firstName, last part as lastName
          String firstName = parts.isNotEmpty ? parts[0] : '';
          String lastName = parts.length > 1 ? parts.last : '';
          String middleName = '';
          
          // If there are more than 2 parts, everything between first and last is middle name
          if (parts.length > 2) {
            middleName = parts.sublist(1, parts.length - 1).join(' ');
          }
          
          await doc.reference.update({
            'firstName': firstName,
            'lastName': lastName,
            'middleName': middleName.isNotEmpty ? middleName : null,
            'fullName': name,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          
          migratedCount++;
          print('Migrated user: ${data['email']} -> $firstName $middleName $lastName');
        }
      }
      
      print('Migration completed. Total users migrated: $migratedCount');
    } catch (e) {
      print('ERROR migrating users: $e');
    }
  }

  // Get users by role
  static Stream<List<Map<String, dynamic>>> getUsersByRole(String role) {
    return _usersCollection
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            
            // Extract name from new structure
            final firstName = data['firstName'] as String? ?? '';
            final lastName = data['lastName'] as String? ?? '';
            final middleName = data['middleName'] as String?;
            
            // Build full name
            String displayName = _buildFullName(firstName, lastName, middleName);
            if (displayName.isEmpty) {
              displayName = data['name'] as String? ?? 'No Name';
            }
            
            return {
              'id': doc.id,
              'name': displayName,
              'firstName': firstName,
              'lastName': lastName,
              'middleName': middleName,
              'fullName': displayName,
              'email': data['email'] ?? '',
              'role': data['role'] ?? 'user',
              'isSuspended': data['isSuspended'] ?? false,
              'createdAt': data['createdAt'],
              'lastActive': data['lastActive'],
              'updatedAt': data['updatedAt'],
            };
          }).toList();
        });
  }

  // Search users
  static Stream<List<Map<String, dynamic>>> searchUsers(String query) {
    return _usersCollection
        .snapshots()
        .map((snapshot) {
          final lowercaseQuery = query.toLowerCase();
          
          return snapshot.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                
                // Extract name from new structure
                final firstName = data['firstName'] as String? ?? '';
                final lastName = data['lastName'] as String? ?? '';
                final middleName = data['middleName'] as String?;
                
                // Build full name
                String displayName = _buildFullName(firstName, lastName, middleName);
                if (displayName.isEmpty) {
                  displayName = data['name'] as String? ?? 'No Name';
                }
                
                return {
                  'id': doc.id,
                  'name': displayName,
                  'firstName': firstName,
                  'lastName': lastName,
                  'middleName': middleName,
                  'fullName': displayName,
                  'email': data['email'] ?? '',
                  'role': data['role'] ?? 'user',
                  'isSuspended': data['isSuspended'] ?? false,
                  'createdAt': data['createdAt'],
                  'lastActive': data['lastActive'],
                  'updatedAt': data['updatedAt'],
                };
              })
              .where((user) {
                // Search in all name fields and email
                final name = user['name'].toString().toLowerCase();
                final firstName = user['firstName'].toString().toLowerCase();
                final lastName = user['lastName'].toString().toLowerCase();
                final email = user['email'].toString().toLowerCase();
                
                return name.contains(lowercaseQuery) ||
                       firstName.contains(lowercaseQuery) ||
                       lastName.contains(lowercaseQuery) ||
                       email.contains(lowercaseQuery);
              })
              .toList();
        });
  }
}