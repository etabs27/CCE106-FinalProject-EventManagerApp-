import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/models/event.dart';
import 'package:event_manager_application_finalproject/event_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  bool _isBooking = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // StreamBuilder to fetch real-time data from Firebase
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .doc(widget.event.id)
          .snapshots(),
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: colorScheme.surface,
              automaticallyImplyLeading: true,
              title: Text(
                'Event Details',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              elevation: 0,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Handle error state
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: colorScheme.surface,
              automaticallyImplyLeading: true,
              title: Text(
                'Event Details',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              elevation: 0,
            ),
            body: Center(
              child: Text(
                'Error loading event details',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),
          );
        }

        // Get updated event data from Firestore
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: colorScheme.surface,
              automaticallyImplyLeading: true,
              title: Text(
                'Event Details',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              elevation: 0,
            ),
            body: Center(
              child: Text(
                'Event not found',
                style: textTheme.bodyMedium,
              ),
            ),
          );
        }

        // Convert Firestore document to Event object
        final updatedEvent = Event.fromDocument(snapshot.data!);

        return _buildEventDetailsUI(
          event: updatedEvent,
          theme: theme,
          colorScheme: colorScheme,
          textTheme: textTheme,
        );
      },
    );
  }

  Widget _buildEventDetailsUI({
    required Event event,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    // Format date and time
    final dateString = event.date.toString().split(' ')[0];
    final startHour = event.startTime.hour;
    final startMinute = event.startTime.minute;
    final endHour = event.endTime.hour;
    final endMinute = event.endTime.minute;
    
    // Format time strings
    final startTimeString = '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
    final endTimeString = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
    final timeRangeString = '$startTimeString - $endTimeString';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        automaticallyImplyLeading: true,
        title: Text(
          'Event Details',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image/Banner
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
              ),
              child: event.imageUrl != null
                  ? Image.network(
                      event.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.event_rounded,
                            size: 80,
                            color: colorScheme.primary.withOpacity(0.5),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.event_rounded,
                        size: 80,
                        color: colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
            ),

            // Event Details Card
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Category Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onBackground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event.category,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Date and Time
                  _buildDetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date & Time',
                    value: '$dateString • $timeRangeString',
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 16),

                  // Location
                  _buildDetailRow(
                    icon: Icons.location_on_rounded,
                    label: 'Location',
                    value: event.venue,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 16),

                  // Full Address
                  _buildDetailRow(
                    icon: Icons.home_rounded,
                    label: 'Address',
                    value: event.fullAddress,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 20),

                  // Capacity and Price Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Capacity
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Capacity',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onBackground.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${event.registeredAttendees ?? 0}/${event.capacity}',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onBackground,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 4,
                              width: 80,
                              decoration: BoxDecoration(
                                color: colorScheme.outline.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 4,
                                    width: 80 *
                                        ((event.registeredAttendees ?? 0) /
                                            event.capacity),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Price',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onBackground.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              event.price != null && event.price! > 0 ? '₱${event.price}' : 'Free',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'About Event',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description ?? 'No description available',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Manager Information
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Event Manager',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.primary.withOpacity(0.1),
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                event.managerEmail,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onBackground,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Book Now Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (event.registeredAttendees ?? 0) >= event.capacity
                          ? null
                          : () => _handleBooking(event, colorScheme),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        disabledBackgroundColor:
                            colorScheme.onBackground.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isBooking
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              (event.registeredAttendees ?? 0) >= event.capacity
                                  ? 'Event Full'
                                  : 'Book Now',
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Back Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: colorScheme.outline,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onBackground.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleBooking(Event event, ColorScheme colorScheme) async {
    setState(() {
      _isBooking = true;
    });

    try {
      await EventService.registerUserForEvent(event.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully booked ${event.title}!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Delay and then pop back
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate booking was successful
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book event: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }
}