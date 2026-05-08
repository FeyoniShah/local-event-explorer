import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import '../../data/event_model.dart';
import '../providers/saved_events_provider.dart';
import '../providers/events_provider.dart';
import '../providers/rsvp_provider.dart';


class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  EventModel? _event;

  Future<void> _openUrl(String url) async {
    if (url.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking link not available')),
        );
      }
      return;
    }

    String fixedUrl = url.trim();

    if (!fixedUrl.startsWith('http://') &&
        !fixedUrl.startsWith('https://')) {
      fixedUrl = 'https://$fixedUrl';
    }

    final uri = Uri.parse(fixedUrl);

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open booking link')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }

  Future<void> _openMapsDirections(EventModel event) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${event.latitude},${event.longitude}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps')),
        );
      }
    }
  }

  void _goToMap(EventModel event) {
    context.go('/map');
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    final searchEventsAsync = ref.watch(searchEventsProvider);

    eventsAsync.whenData((events) {
      if (_event == null) {
        try {
          final found = events.firstWhere((e) => e.id == widget.eventId);
          if (mounted) {
            setState(() => _event = found);
          }
        } catch (_) {}
      }
    });

    searchEventsAsync.whenData((events) {
      if (_event == null) {
        try {
          final found = events.firstWhere((e) => e.id == widget.eventId);
          if (mounted) {
            setState(() => _event = found);
          }
        } catch (_) {}
      }
    });

    if (_event == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final event = _event!;
    final isSaved = ref.watch(savedEventsProvider.notifier).isSaved(event.id);

    final isRsvpd = ref.watch(rsvpProvider).isRsvpd(event.id);
    final eventPassed = event.dateTime.isBefore(
      DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    event.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.event,
                        size: 80,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_outline,
                  color: isSaved ? Colors.amber : Colors.white,
                ),
                onPressed: () {
                  ref.read(savedEventsProvider.notifier).toggleSave(event);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isSaved ? 'Removed from saved!' : 'Event saved!',
                      ),
                      backgroundColor: isSaved ? Colors.grey : Colors.green,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          '${_getCategoryEmoji(event.category)} ${event.category.toUpperCase()}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor:
                        _getCategoryColor(event.category).withOpacity(0.2),
                        side: BorderSide(
                          color: _getCategoryColor(event.category),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          '📍 ${event.city}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.grey.withOpacity(0.1),
                      ),
                      if (isRsvpd) ...[
                        const SizedBox(width: 8),
                        const Chip(
                          label: Text(
                            '✅ Going',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _infoRow(
                            Icons.calendar_today,
                            'Date',
                            '${_dayName(event.dateTime.weekday)}, ${event.dateTime.day} ${_monthName(event.dateTime.month)} ${event.dateTime.year}',
                          ),
                          const Divider(height: 16),
                          _infoRow(
                            Icons.access_time,
                            'Time',
                            event.dateTime.hour == 0 &&
                                event.dateTime.minute == 0
                                ? 'Check event page for time'
                                : '${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}',
                          ),
                          const Divider(height: 16),
                          _infoRow(
                            Icons.location_on,
                            'Venue',
                            event.venue,
                          ),
                          const Divider(height: 16),
                          _infoRow(
                            Icons.confirmation_number,
                            'Price',
                            event.isFree
                                ? 'Free Entry'
                                : event.price != null
                                ? '₹${event.price!.toStringAsFixed(0)}'
                                : 'Check event page for price',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  InkWell(
                    onTap: () => _openMapsDirections(event),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue.withOpacity(0.05),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.map,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Get Directions',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  event.venue,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  OutlinedButton.icon(
                    onPressed: () => _goToMap(event),
                    icon: const Icon(Icons.pin_drop),
                    label: const Text('View on App Map'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const Divider(height: 32),

                  Text(
                    'About This Event',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  if (event.externalUrl != null &&
                      event.externalUrl!.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openUrl(event.externalUrl!),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('More Details & Book Tickets'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  if (!eventPassed)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await ref
                              .read(rsvpProvider.notifier)
                              .toggleRsvp(event);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isRsvpd
                                      ? 'RSVP removed — you are no longer marked as going'
                                      : 'You are going! Check your profile for this event.',
                                ),
                                backgroundColor: isRsvpd
                                    ? Colors.grey[700]
                                    : Colors.green[700],
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          isRsvpd
                              ? Icons.check_circle
                              : Icons.event_available,
                        ),
                        label: Text(
                          isRsvpd
                              ? "I'm Going ✓ (tap to undo)"
                              : "RSVP — I'm Going!",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          isRsvpd ? Colors.green[700] : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                  else if (isRsvpd)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'You attended this event',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref
                            .read(savedEventsProvider.notifier)
                            .toggleSave(event);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isSaved ? 'Removed from saved!' : 'Event saved!',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_outline,
                      ),
                      label: Text(isSaved ? 'Saved' : 'Save Event'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'music':
        return '🎵';
      case 'sports':
        return '🏏';
      case 'art':
        return '🎭';
      case 'tech':
        return '💻';
      case 'food':
        return '🍴';
      case 'community':
        return '🤝';
      default:
        return '🎪';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'music':
        return Colors.purple;
      case 'sports':
        return Colors.green;
      case 'art':
        return Colors.orange;
      case 'tech':
        return Colors.blue;
      case 'food':
        return Colors.red;
      default:
        return Colors.teal;
    }
  }

  String _dayName(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(day - 1).clamp(0, 6)];
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}