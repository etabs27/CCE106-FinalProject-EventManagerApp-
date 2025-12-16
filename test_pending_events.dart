import 'package:event_manager_application_finalproject/event_service.dart';
import 'package:event_manager_application_finalproject/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('Testing getPendingEvents method...');

  try {
    // Get pending events
    final events = await EventService.getPendingEvents().first;
    print('✅ SUCCESS: Found ${events.length} pending events');

    for (var event in events) {
      print('  - ${event.title} by ${event.managerEmail} (status: ${event.status})');
    }
  } catch (e) {
    print('❌ ERROR: $e');
  }
}