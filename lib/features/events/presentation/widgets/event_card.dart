import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/event_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final Position? userPosition;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.userPosition,
  });

  String _getDistance() {
    if (userPosition == null) return '';
    final dist = Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      event.latitude,
      event.longitude,
    );
    if (dist < 1000) return '${dist.toStringAsFixed(0)}m away';
    return '${(dist / 1000).toStringAsFixed(1)}km away';
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'music': return Colors.purple;
      case 'sports': return Colors.green;
      case 'art': return Colors.orange;
      case 'tech': return Colors.blue;
      case 'food': return Colors.red;
      case 'community': return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'music': return Icons.music_note;
      case 'sports': return Icons.sports_cricket;
      case 'art': return Icons.palette;
      case 'tech': return Icons.computer;
      case 'food': return Icons.restaurant;
      case 'community': return Icons.people;
      default: return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    final distance = _getDistance();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                Image.network(
                  event.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: Colors.grey[800],
                    child: Icon(_categoryIcon(event.category),
                        size: 60, color: Colors.white54),
                  ),
                ),
                // Category badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _categoryColor(event.category),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_categoryIcon(event.category),
                            size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          event.category.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                // Price badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: event.isFree ? Colors.green : Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.isFree
                          ? 'FREE'
                          : '₹${event.price?.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(event.title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),

                  // Date + Time
                  Row(children: [
                    const Icon(Icons.calendar_today,
                        size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${event.dateTime.day} ${_month(event.dateTime.month)} • ${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12),
                    ),
                  ]),
                  const SizedBox(height: 4),

                  // Venue + Distance
                  Row(children: [
                    const Icon(Icons.location_on,
                        size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(event.venue,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (distance.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(distance,
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 11)),
                      ),
                    ],
                  ]),

                  // Attendees
                  if (event.attendeeCount > 0) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.people,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${event.attendeeCount} attending',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _month(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m - 1];
  }
}