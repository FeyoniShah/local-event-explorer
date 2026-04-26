import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/event_model.dart';
import '../../data/dummy_events.dart';
 
class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});
  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}
 
class _EventDetailScreenState extends State<EventDetailScreen> {
  late EventModel event;
  bool isSaved = false;
 
  @override
  void initState() {
    super.initState();
    event = dummyEvents.firstWhere((e) => e.id == widget.eventId,
        orElse: () => dummyEvents.first);
    isSaved = event.isSaved;
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(event.imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.image, size: 60, color: Colors.white)),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_outline),
                onPressed: () => setState(() => isSaved = !isSaved),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(label: Text(event.category.toUpperCase())),
                  const SizedBox(height: 8),
                  Text(event.title, style: Theme.of(context)
                      .textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _infoRow(Icons.calendar_today,
                      "${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year}  ${event.dateTime.hour}:${event.dateTime.minute.toString().padLeft(2, '0')}"),
                  _infoRow(Icons.location_on, event.venue),
                  _infoRow(Icons.confirmation_number,
                      event.isFree ? "Free Entry" : "₹${event.price?.toStringAsFixed(0)}"),
                  _infoRow(Icons.people, "${event.attendeeCount} people attending"),
                  const Divider(height: 32),
                  Text("About", style: Theme.of(context).textTheme
                      .titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(event.description),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("RSVP confirmed! 🎉"),
                            backgroundColor: Colors.green)),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("RSVP / Join"),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Chat coming soon!"))),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text("Join Group Chat"),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ]),
    );
  }
}
