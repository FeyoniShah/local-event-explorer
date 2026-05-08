import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/event_model.dart';
import '../providers/events_provider.dart';
import '../providers/saved_events_provider.dart';
import '../widgets/event_card.dart';
import '../widgets/category_chip.dart';
import '../providers/rsvp_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'all';
  final List<String> _categories = [
    'all',
    'music',
    'tech',
    'art',
    'sports',
    'food'
  ];

  List<EventModel> _filterByCategory(List<EventModel> events) {
    if (_selectedCategory == 'all') return events;
    return events
        .where((e) => e.category.toLowerCase() == _selectedCategory)
        .toList();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    // Watch recommended events — AI sorted
    final eventsAsync = ref.watch(eventsProvider);
    final savedEvents = ref.watch(savedEventsProvider);
    final rsvpState = ref.watch(rsvpProvider);
    final expiringEvents = rsvpState.expiringSoon;
    //final filtered = _filterByCategory(recommended);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting(),
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const Text(
              'Discover Events',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              if (expiringEvents.isEmpty) {
                showDialog(
                  context: context,
                  builder: (_) => const AlertDialog(
                    title: Text('No Notifications'),
                    content: Text('No RSVP events are expiring soon.'),
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Upcoming RSVP Reminders'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: ListView(
                          shrinkWrap: true,
                          children: expiringEvents.map((event) {
                            return ListTile(
                              leading: const Icon(Icons.notifications_active),
                              title: Text(event.title),
                              subtitle: Text(
                                'Event is within 1 day\n${event.venue}',
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Error: $err'),
        ),
        data: (events) {
          final savedEvents = ref.watch(savedEventsProvider);
          final filtered = _filterByCategory(events);

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: GestureDetector(
                  onTap: () => context.push('/search'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey, size: 20),
                        SizedBox(width: 8),
                        Text('Search events, venues...',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),

              // Category chips
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return CategoryChip(
                      label: cat[0].toUpperCase() + cat.substring(1),
                      isSelected: cat == _selectedCategory,
                      onTap: () => setState(() => _selectedCategory = cat),
                    );
                  },
                ),
              ),

              // AI label
              if (filtered.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome,
                          size: 16, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        'Recommended for you',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

              // Events list
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy,
                                size: 60, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('No events in this category',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final event = filtered[index];
                          final isSaved =
                              savedEvents.any((e) => e.id == event.id);

                          return EventCard(
                            event: event,
                            onTap: () => context.push('/event/${event.id}'),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
