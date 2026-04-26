import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../routing/app_router.dart';
 
class InterestPickerScreen extends StatefulWidget {
  const InterestPickerScreen({super.key});
  @override
  State<InterestPickerScreen> createState() => _InterestPickerScreenState();
}
 
class _InterestPickerScreenState extends State<InterestPickerScreen> {
  final List<Map<String, dynamic>> _interests = [
    {'label': 'Music', 'icon': Icons.music_note, 'selected': false},
    {'label': 'Tech', 'icon': Icons.computer, 'selected': false},
    {'label': 'Art', 'icon': Icons.palette, 'selected': false},
    {'label': 'Sports', 'icon': Icons.sports_cricket, 'selected': false},
    {'label': 'Food', 'icon': Icons.restaurant, 'selected': false},
    {'label': 'Travel', 'icon': Icons.flight, 'selected': false},
    {'label': 'Comedy', 'icon': Icons.sentiment_very_satisfied, 'selected': false},
    {'label': 'Wellness', 'icon': Icons.self_improvement, 'selected': false},
  ];
 
  int get _selectedCount =>
      _interests.where((i) => i['selected'] == true).length;
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Your Interests")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("What do you love?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text("Pick at least 2 to personalise your feed",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 12,
                    mainAxisSpacing: 12, childAspectRatio: 1.8),
                itemCount: _interests.length,
                itemBuilder: (context, index) {
                  final item = _interests[index];
                  final isSelected = item["selected"] as bool;
                  return GestureDetector(
                    onTap: () => setState(
                        () => _interests[index]['selected'] = !isSelected),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item["icon"] as IconData,
                              size: 32,
                              color: isSelected ? Colors.white : null),
                          const SizedBox(height: 8),
                          Text(item["label"] as String,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : null)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedCount >= 2
                    ? () => context.go(AppRoutes.home)
                    : null,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(_selectedCount >= 2
                    ? "Let's Go! 🎉" : "Pick at least 2"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
