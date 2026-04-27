import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/events_provider.dart';
import '../widgets/event_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, String>> _popularCities = [
    {'label': '🏙️ Pune', 'query': 'Pune'},
    {'label': '🌊 Mumbai', 'query': 'Mumbai'},
    {'label': '🏛️ Delhi', 'query': 'Delhi'},
    {'label': '💻 Bangalore', 'query': 'Bangalore'},
    {'label': '🕌 Hyderabad', 'query': 'Hyderabad'},
    {'label': '🎵 Chennai', 'query': 'Chennai'},
    {'label': '🎭 Kolkata', 'query': 'Kolkata'},
    {'label': '🏖️ Goa', 'query': 'Goa'},
    {'label': '🏰 Jaipur', 'query': 'Jaipur'},
    {'label': '🪁 Ahmedabad', 'query': 'Ahmedabad'},
  ];

  final List<Map<String, String>> _quickSearches = [
    {'label': '🎵 Concerts', 'query': 'concerts music shows India'},
    {'label': '🏏 Cricket & IPL', 'query': 'IPL cricket match India'},
    {'label': '😂 Comedy Shows', 'query': 'standup comedy India'},
    {'label': '💃 Dance Events', 'query': 'dance performance India'},
    {'label': '💻 Tech Meetups', 'query': 'tech meetup workshop India'},
    {'label': '🎪 Festivals', 'query': 'festival mela fair India'},
    {'label': '🧘 Wellness', 'query': 'yoga wellness India'},
    {'label': '🎨 Art & Theatre', 'query': 'art theatre exhibition India'},
  ];

  void _doSearch(String query) {
    if (query.trim().isEmpty) return;
    ref.read(searchQueryProvider.notifier).state = query.trim();
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final eventsAsync = ref.watch(searchEventsProvider);
    final locationAsync = ref.watch(locationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search Events')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: _doSearch,
              decoration: InputDecoration(
                hintText: 'Search events, city, artist...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear), onPressed: _clearSearch)
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => _doSearch(_controller.text)),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
          ),

          // Before search: chips
          if (query.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text('Quick Search',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _quickSearches.length,
                itemBuilder: (context, i) {
                  final item = _quickSearches[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(item['label']!),
                      onPressed: () {
                        _controller.text = item['label']!;
                        _doSearch(item['query']!);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text('Browse by City',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _popularCities
                    .map((item) => ActionChip(
                          label: Text(item['label']!),
                          onPressed: () {
                            _controller.text = item['query']!;
                            _doSearch(item['query']!);
                          },
                        ))
                    .toList(),
              ),
            ),
          ],

          // Results
          if (query.isNotEmpty)
            Expanded(
              child: eventsAsync.when(
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Searching real events...',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('Could not fetch events',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.refresh(searchEventsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (events) {
                  if (events.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off,
                              size: 60, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text('No upcoming events found',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16)),
                          const SizedBox(height: 4),
                          const Text('Try a different city or keyword',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                              onPressed: _clearSearch,
                              child: const Text('Search Again')),
                        ],
                      ),
                    );
                  }
                  return locationAsync.when(
                    loading: () => _buildList(events, null),
                    error: (_, __) => _buildList(events, null),
                    data: (pos) => _buildList(events, pos),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildList(List events, position) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.green.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(children: [
            const Icon(Icons.check_circle, size: 14, color: Colors.green),
            const SizedBox(width: 6),
            Text('${events.length} upcoming events found',
                style: const TextStyle(fontSize: 12, color: Colors.green)),
            if (position != null) ...[
              const SizedBox(width: 8),
              const Text('• sorted nearest first',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: events.length,
            itemBuilder: (context, index) => EventCard(
              event: events[index],
              userPosition: position,
              onTap: () => context.push('/event/${events[index].id}'),
            ),
          ),
        ),
      ],
    );
  }
}
