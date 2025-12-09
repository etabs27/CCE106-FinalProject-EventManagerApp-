import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';

class ManagerManualCheckinPage extends StatefulWidget {
  const ManagerManualCheckinPage({super.key});

  @override
  State<ManagerManualCheckinPage> createState() => _ManagerManualCheckinPageState();
}

class _ManagerManualCheckinPageState extends State<ManagerManualCheckinPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Attendee> attendees = [
    Attendee(
      name: 'John Doe',
      bookingId: 'EVT-2024-12345',
      ticketCount: 2,
      status: 'Pending',
    ),
    Attendee(
      name: 'Maria Santos',
      bookingId: 'EVT-2024-12346',
      ticketCount: 1,
      status: 'Checked In',
      checkinTime: '6:15 PM',
    ),
    Attendee(
      name: 'Robert Perez',
      bookingId: 'EVT-2024-12347',
      ticketCount: 3,
      status: 'Pending',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        automaticallyImplyLeading: true,
        title: Text(
          'Manual Check-in',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.onSurface.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or booking ID...',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.5),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: colorScheme.onBackground.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onBackground,
                  ),
                  onChanged: (value) {
                    // Implement search functionality
                  },
                ),
              ),
            ),

            // Attendees List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: attendees.length,
                itemBuilder: (context, index) {
                  return _buildAttendeeCard(attendees[index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendeeCard(Attendee attendee, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    attendee.name,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: attendee.status == 'Checked In'
                        ? Colors.green.withOpacity(0.1)
                        : colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: attendee.status == 'Checked In'
                          ? Colors.green.withOpacity(0.3)
                          : colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    attendee.status,
                    style: textTheme.bodySmall?.copyWith(
                      color: attendee.status == 'Checked In'
                          ? Colors.green
                          : colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Booking ID
            Text(
              attendee.bookingId,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),

            // Ticket Count
            Row(
              children: [
                Icon(
                  Icons.confirmation_number_rounded,
                  color: colorScheme.onBackground.withOpacity(0.6),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${attendee.ticketCount} ${attendee.ticketCount > 1 ? 'Tickets' : 'Ticket'}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (attendee.status == 'Checked In') ...[
              // Check-in Time
              Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Checked in at ${attendee.checkinTime}',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Check In Button
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    _checkInAttendee(index);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Check In',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _checkInAttendee(int index) {
    setState(() {
      attendees[index] = attendees[index].copyWith(
        status: 'Checked In',
        checkinTime: _getCurrentTime(),
      );
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${attendees[index].name} checked in successfully!',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }
}

class Attendee {
  final String name;
  final String bookingId;
  final int ticketCount;
  String status;
  String? checkinTime;

  Attendee({
    required this.name,
    required this.bookingId,
    required this.ticketCount,
    required this.status,
    this.checkinTime,
  });

  Attendee copyWith({
    String? name,
    String? bookingId,
    int? ticketCount,
    String? status,
    String? checkinTime,
  }) {
    return Attendee(
      name: name ?? this.name,
      bookingId: bookingId ?? this.bookingId,
      ticketCount: ticketCount ?? this.ticketCount,
      status: status ?? this.status,
      checkinTime: checkinTime ?? this.checkinTime,
    );
  }
}