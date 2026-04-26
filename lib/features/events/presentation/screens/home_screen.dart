import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/dummy_events.dart';
import '../../data/event_model.dart';
import '../widgets/event_card.dart';
import '../widgets/category_chip.dart';
import '../../../../routing/app_router.dart';
 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
 
class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'all';
  final List<String> _categories = ['all', 'music', 'tech', 'art', 'sports', 'food'];
 
  List<EventModel> get _filtered {
    if (_selectedCategory == 'all') return dummyEvents;
    return dummyEvents
        .where((e) => e.category == _selectedCategory).toList();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Local Events"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
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
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text("No events in this category"))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      return EventCard(
                        event: _filtered[index],
                        onTap: () => context.push(
                            '/event/${_filtered[index].id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
