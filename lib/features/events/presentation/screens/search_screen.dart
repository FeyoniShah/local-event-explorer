import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/dummy_events.dart';
import '../../data/event_model.dart';
 
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}
 
class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  String _selectedCategory = 'all';
  final List<String> _categories = ['all','music','tech','art','sports','food'];
 
  List<EventModel> get _filtered {
    return dummyEvents.where((e) {
      final matchesQuery = e.title.toLowerCase().contains(_query.toLowerCase())
          || e.venue.toLowerCase().contains(_query.toLowerCase());
      final matchesCategory = _selectedCategory == "all"
          || e.category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Events")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              onChanged: (val) => setState(() => _query = val),
              decoration: InputDecoration(
                hintText: "Search events, venues...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear),
                        onPressed: () { _controller.clear();
                          setState(() => _query = ''); })
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat[0].toUpperCase() + cat.substring(1)),
                    selected: cat == _selectedCategory,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.search_off, size: 60, color: Colors.grey),
                      SizedBox(height: 12),
                      Text("No events found", style: TextStyle(color: Colors.grey))],))
                : ListView.builder(
                    itemCount: _filtered.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final event = _filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(event.imageUrl,
                              width: 60, height: 60, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60, height: 60, color: Colors.grey[800],
                                child: const Icon(Icons.image))),
                          ),
                          title: Text(event.title, style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                          subtitle: Text("${event.venue}\n${event.isFree ? 'Free' : '₹${event.price?.toStringAsFixed(0)}'}"),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push("/event/${event.id}"),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
