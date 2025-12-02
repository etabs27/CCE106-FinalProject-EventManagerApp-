import 'package:flutter_test/flutter_test.dart';
import 'package:event_manager_application_finalproject/auth_service.dart';

void main() {
  test('AuthService returns correct roles for test accounts', () async {
    final userRole = await AuthService.signIn('user@example.com', 'user123');
    final managerRole = await AuthService.signIn('manager@example.com', 'manager123');
    final adminRole = await AuthService.signIn('admin@example.com', 'admin123');

    expect(userRole, 'user');
    expect(managerRole, 'manager');
    expect(adminRole, 'admin');
  });

  test('AuthService rejects invalid credentials', () async {
    final noUser = await AuthService.signIn('not@found.com', 'x');
    final wrongPass = await AuthService.signIn('user@example.com', 'wrongpass');

    expect(noUser, isNull);
    expect(wrongPass, isNull);
  });
}
