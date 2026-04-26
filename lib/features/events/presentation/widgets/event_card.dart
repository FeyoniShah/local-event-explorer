import 'package:flutter/material.dart';
import '../../data/event_model.dart';
 
class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  const EventCard({super.key, required this.event, required this.onTap});
 
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              event.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: Colors.grey[800],
                child: const Icon(Icons.image, size: 60, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(event.category.toUpperCase(),
                            style: const TextStyle(fontSize: 10)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                      const Spacer(),
                      Text(
                        event.isFree
                            ? 'FREE'
                            : '₹${event.price?.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: event.isFree ? Colors.green : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(event.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14,
                          color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(child: Text(event.venue,
                          style: const TextStyle(color: Colors.grey,
                              fontSize: 13),
                          overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 14,
                          color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("${event.attendeeCount} attending",
                          style: const TextStyle(color: Colors.grey,
                              fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
