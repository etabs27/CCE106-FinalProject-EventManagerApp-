# event_manager_application_finalproject

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Test accounts (local / testing)

During development there are three built-in test accounts you can use from the login screen. They are implemented in `lib/auth/auth_service.dart` and intended for local testing only — do not use in production.

Credentials:

- User: user@example.com / user123  (navigates to the user home)
- Manager: manager@example.com / manager123  (navigates to the manager dashboard)
- Admin: admin@example.com / admin123  (navigates to the admin panel)

The login screen previously included quick buttons to autofill and sign in as each test user; those buttons have been removed. You can still use the credentials below to sign in manually using the main Sign In button.
