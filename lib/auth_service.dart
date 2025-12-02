import 'dart:async';

/// Very small in-memory auth service used for development/testing only.
///
/// Adds three test accounts (user / manager / admin) so the developer can
/// quickly sign in and navigate to the role-specific UIs.
class AuthService {
  // Keep credentials simple & explicit for manual testing.
  // DO NOT use this for production.
  static final Map<String, Map<String, String>> _accounts = {
    // email: {password, role, displayName}
    'user@example.com': {
      'password': 'user123',
      'role': 'user',
      'displayName': 'Test User',
    },
    'manager@example.com': {
      'password': 'manager123',
      'role': 'manager',
      'displayName': 'Sarah Manager',
    },
    'admin@example.com': {
      'password': 'admin123',
      'role': 'admin',
      'displayName': 'System Administrator',
    },
  };

  /// Simulates signing in. Returns the user's role on success, otherwise null.
  /// A short artificial delay is added to mimic async behavior.
  static Future<String?> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final acct = _accounts[email.trim().toLowerCase()];
    if (acct == null) return null;
    if (acct['password'] == password) return acct['role'];
    return null;
  }

  /// Return a human friendly name for the account, handy for UI personalization.
  static String? displayNameFor(String email) {
    final acct = _accounts[email.trim().toLowerCase()];
    return acct == null ? null : acct['displayName'];
  }

  /// Returns the test accounts so UI/tests can show them or iterate.
  static Map<String, Map<String, String>> get testAccounts => _accounts;
}
