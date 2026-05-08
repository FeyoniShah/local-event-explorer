import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../routing/app_router.dart';

class InterestPickerScreen extends StatefulWidget {
  const InterestPickerScreen({super.key});

  @override
  State<InterestPickerScreen> createState() => _InterestPickerScreenState();
}

class _InterestPickerScreenState extends State<InterestPickerScreen> {
  bool _loading = false;

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

  @override
  void initState() {
    super.initState();
    _loadExistingInterests();
  }

  int get _selectedCount =>
      _interests.where((i) => i['selected'] == true).length;

  List<String> get _selectedLabels => _interests
      .where((i) => i['selected'] == true)
      .map((i) => i['label'] as String)
      .toList();

  Future<void> _loadExistingInterests() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final existingInterests = (doc.data()?['interests'] as List?)
          ?.map((e) => e.toString())
          .toList();

      if (existingInterests == null) return;

      setState(() {
        for (final item in _interests) {
          item['selected'] = existingInterests.contains(item['label']);
        }
      });
    } catch (e) {
      print('Error loading interests: $e');
    }
  }

  Future<void> _onLetsGo() async {
    if (_selectedCount < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pick at least 2 interests'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      await prefs.setStringList('user_interests', _selectedLabels);

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'displayName':
          user.displayName ?? user.email?.split('@').first ?? 'Guest',
          'email': user.email ?? 'guest@local.app',
          'photoUrl': user.photoURL ?? '',
          'interests': _selectedLabels,
          'onboardingComplete': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      print('Error saving interests: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving interests: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Your Interests'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What do you love?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Pick at least 2 to personalise your feed',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.8,
                ),
                itemCount: _interests.length,
                itemBuilder: (context, index) {
                  final item = _interests[index];
                  final isSelected = item['selected'] as bool;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _interests[index]['selected'] = !isSelected;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 32,
                            color: isSelected ? Colors.white : null,
                          ),

                          const SizedBox(height: 8),

                          Text(
                            item['label'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                _selectedCount == 0
                    ? 'Select at least 2'
                    : '$_selectedCount selected',
                style: const TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _selectedCount >= 2 ? _onLetsGo : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _selectedCount >= 2
                      ? 'Save Interests'
                      : 'Pick at least 2',
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}