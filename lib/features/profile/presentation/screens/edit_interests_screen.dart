import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditInterestsScreen extends StatefulWidget {
  const EditInterestsScreen({super.key});

  @override
  State<EditInterestsScreen> createState() => _EditInterestsScreenState();
}

class _EditInterestsScreenState extends State<EditInterestsScreen> {
  final List<Map<String, dynamic>> _allInterests = [
    {'label': 'Music',     'icon': Icons.music_note},
    {'label': 'Tech',      'icon': Icons.computer},
    {'label': 'Sports',    'icon': Icons.sports_soccer},
    {'label': 'Food',      'icon': Icons.restaurant},
    {'label': 'Art',       'icon': Icons.palette},
    {'label': 'Business',  'icon': Icons.business_center},
    {'label': 'Gaming',    'icon': Icons.sports_esports},
    {'label': 'Fitness',   'icon': Icons.fitness_center},
    {'label': 'Movies',    'icon': Icons.movie},
    {'label': 'Education', 'icon': Icons.school},
    {'label': 'Comedy',    'icon': Icons.sentiment_very_satisfied},
    {'label': 'Community', 'icon': Icons.people},
  ];

  List<String> _selected = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadInterests();
  }

  Future<void> _loadInterests() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { setState(() => _loading = false); return; }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        _selected = List<String>.from(data?['interests'] ?? []);
      }
    } catch (_) {}

    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one interest')),
      );
      return;
    }

    setState(() => _saving = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'interests': _selected}, SetOptions(merge: true));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interests updated! 🎉'),
            backgroundColor: Color(0xFF4CAF82),
          ),
        );
        Navigator.pop(context, true); // return true so profile refreshes
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }

    setState(() => _saving = false);
  }

  void _toggle(String label) {
    setState(() {
      _selected.contains(label)
          ? _selected.remove(label)
          : _selected.add(label);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Interests'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Save',
                    style: TextStyle(
                        color: primary, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    'What are you into?',
                    style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Text(
                    'Select all that apply — we\'ll personalize your feed',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),

                // Interest chips grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _allInterests.length,
                    itemBuilder: (context, i) {
                      final item = _allInterests[i];
                      final label = item['label'] as String;
                      final icon = item['icon'] as IconData;
                      final isSelected = _selected.contains(label);

                      return GestureDetector(
                        onTap: () => _toggle(label),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primary.withOpacity(0.15)
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? primary : Colors.grey.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon,
                                  size: 32,
                                  color: isSelected ? primary : Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected ? primary : null,
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle,
                                    size: 14, color: primary),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom selected count + save button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    children: [
                      Text(
                        '${_selected.length} selected',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? const SizedBox(
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Save Interests'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}