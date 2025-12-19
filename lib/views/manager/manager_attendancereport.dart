import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/models/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerAttendanceReportPage extends StatefulWidget {
  final String eventId;

  const ManagerAttendanceReportPage({super.key, required this.eventId});

  @override
  State<ManagerAttendanceReportPage> createState() => _ManagerAttendanceReportPageState();
}

class _ManagerAttendanceReportPageState extends State<ManagerAttendanceReportPage> {
  late Stream<DocumentSnapshot> _eventStream;
  late Stream<QuerySnapshot> _ticketsStream;

  @override
  void initState() {
    super.initState();
    _eventStream = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .snapshots();
    _ticketsStream = FirebaseFirestore.instance
        .collection('tickets')
        .where('eventId', isEqualTo: widget.eventId)
        .snapshots();
  }

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
          'Attendance Report',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _eventStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading event data: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Event not found'),
            );
          }

          final event = Event.fromFirestore(snapshot.data!);
          final registered = event.registeredAttendees ?? 0;
          final checkedIn = event.checkedInAttendees ?? 0;
          final pending = registered - checkedIn;
          final noShows = 0; // Assuming no-shows are not tracked yet

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Title
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            event.title,
                            style: textTheme.titleLarge?.copyWith(
                              color: colorScheme.onBackground,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Attendance Summary',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onBackground.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Attendance Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Total Registered',
                            value: registered.toString(),
                            icon: Icons.people_alt_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Checked In',
                            value: checkedIn.toString(),
                            icon: Icons.check_circle_rounded,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Pending',
                            value: pending.toString(),
                            icon: Icons.pending_rounded,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: 'No-shows',
                            value: noShows.toString(),
                            icon: Icons.no_accounts_rounded,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Detailed Attendance List
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attendee Details',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onBackground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          StreamBuilder<QuerySnapshot>(
                            stream: _ticketsStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }

                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: Text(
                                      'No attendees yet',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onBackground.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final tickets = snapshot.data!.docs;

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: tickets.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final ticket = tickets[index].data() as Map<String, dynamic>;
                                  final attendeeName = ticket['userName'] ?? 'Unknown';
                                  final attendeeEmail = ticket['userEmail'] ?? 'No email';
                                  final isCheckedIn = ticket['isCheckedIn'] ?? false;
                                  final checkInTime = ticket['checkInTime'];

                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: colorScheme.outline.withOpacity(0.1),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: isCheckedIn ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isCheckedIn ? Icons.check_circle_rounded : Icons.pending_rounded,
                                            color: isCheckedIn ? Colors.green : Colors.orange,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                attendeeName,
                                                style: textTheme.bodyLarge?.copyWith(
                                                  color: colorScheme.onBackground,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                attendeeEmail,
                                                style: textTheme.bodySmall?.copyWith(
                                                  color: colorScheme.onBackground.withOpacity(0.6),
                                                ),
                                              ),
                                              if (isCheckedIn && checkInTime != null)
                                                Text(
                                                  'Checked in: ${_formatDateTime(checkInTime)}',
                                                  style: textTheme.bodySmall?.copyWith(
                                                    color: Colors.green,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              if (!isCheckedIn)
                                                Text(
                                                  'Not checked in',
                                                  style: textTheme.bodySmall?.copyWith(
                                                    color: Colors.orange,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      height: 100,
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
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (color ?? colorScheme.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color ?? colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.65),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (timestamp is String) {
        return timestamp;
      } else {
        return 'Unknown time';
      }
    } catch (e) {
      return 'Invalid time';
    }
  }
}