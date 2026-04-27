import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/events_provider.dart';
import '../widgets/event_card.dart';
import '../widgets/category_chip.dart';
import '../../data/dummy_events.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'all';

  final List<Map<String, String>> _categories = [
    {'key': 'all', 'label': '🌐 All'},
    {'key': 'music', 'label': '🎵 Music'},
    {'key': 'sports', 'label': '🏏 Sports'},
    {'key': 'art', 'label': '🎭 Theatre & Art'},
    {'key': 'tech', 'label': '💻 Tech & Expos'},
    {'key': 'food', 'label': '🍴 Festivals'},
    {'key': 'community', 'label': '🤝 Community'},
  ];

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    final locationAsync = ref.watch(locationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events Near You'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Location status
          locationAsync.when(
            loading: () => Container(
              width: double.infinity,
              color: Colors.blue.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(
                  vertical: 6, horizontal: 16),
              child: const Row(children: [
                SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
                Text('Getting your location...',
                    style: TextStyle(fontSize: 12, color: Colors.blue)),
              ]),
            ),
            error: (_, __) => const SizedBox(),
            data: (position) => position != null
                ? Container(
                    width: double.infinity,
                    color: Colors.green.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 16),
                    child: const Row(children: [
                      Icon(Icons.location_on,
                          size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text('Showing events nearest to you',
                          style: TextStyle(
                              fontSize: 12, color: Colors.green)),
                    ]),
                  )
                : const SizedBox(),
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
                  label: cat['label']!,
                  isSelected: cat['key'] == _selectedCategory,
                  onTap: () =>
                      setState(() => _selectedCategory = cat['key']!),
                );
              },
            ),
          ),

          // Events
          Expanded(
            child: eventsAsync.when(
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Finding events across India...',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              error: (_, __) =>
                  _buildList(dummyEvents, isLocal: true),
              data: (events) {
                final source =
                    events.isEmpty ? dummyEvents : events;
                final filtered = _selectedCategory == 'all'
                    ? source
                    : source
                        .where(
                            (e) => e.category == _selectedCategory)
                        .toList();
                return _buildList(filtered,
                    isLocal: events.isEmpty);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List events, {bool isLocal = false}) {
    final locationAsync = ref.watch(locationProvider);

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('No events in this category',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  setState(() => _selectedCategory = 'all'),
              child: const Text('Show All Events'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (isLocal)
          Container(
            width: double.infinity,
            color: Colors.amber.withOpacity(0.15),
            padding: const EdgeInsets.symmetric(
                vertical: 6, horizontal: 16),
            child: const Row(children: [
              Icon(Icons.info_outline, size: 16, color: Colors.amber),
              SizedBox(width: 8),
              Text('Showing sample events',
                  style:
                      TextStyle(fontSize: 12, color: Colors.amber)),
            ]),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.refresh(eventsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return locationAsync.when(
                  loading: () => EventCard(
                    event: events[index],
                    onTap: () =>
                        context.push('/event/${events[index].id}'),
                  ),
                  error: (_, __) => EventCard(
                    event: events[index],
                    onTap: () =>
                        context.push('/event/${events[index].id}'),
                  ),
                  data: (position) => EventCard(
                    event: events[index],
                    userPosition: position,
                    onTap: () =>
                        context.push('/event/${events[index].id}'),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}