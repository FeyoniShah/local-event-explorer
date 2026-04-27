// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../../core/theme/app_theme.dart';

// // Key used by app_router.dart redirect to know onboarding is done
// const String kOnboardingComplete = 'onboarding_complete';

// class InterestPickerScreen extends StatefulWidget {
//   const InterestPickerScreen({super.key});

//   @override
//   State<InterestPickerScreen> createState() => _InterestPickerScreenState();
// }

// class _InterestPickerScreenState extends State<InterestPickerScreen> {
//   final Set<String> _selected = {};
//   bool _loading = false;

//   final List<_InterestItem> _interests = const [
//     _InterestItem('Music', Icons.music_note_rounded, AppColors.catMusic),
//     _InterestItem('Tech', Icons.computer_rounded, AppColors.catTech),
//     _InterestItem('Art', Icons.palette_rounded, AppColors.catArt),
//     _InterestItem('Sports', Icons.sports_soccer_rounded, AppColors.catSports),
//     _InterestItem('Food', Icons.restaurant_rounded, AppColors.catFood),
//     _InterestItem(
//         'Business', Icons.business_center_rounded, AppColors.catBusiness),
//     _InterestItem('Gaming', Icons.sports_esports_rounded, AppColors.primary),
//     _InterestItem('Travel', Icons.flight_rounded, AppColors.accent),
//     _InterestItem('Health', Icons.favorite_rounded, AppColors.success),
//     _InterestItem(
//         'Comedy', Icons.sentiment_very_satisfied_rounded, AppColors.warning),
//   ];

//   Future<void> _onLetsGo() async {
//     if (_selected.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Pick at least one interest to continue'),
//           backgroundColor: AppColors.error,
//         ),
//       );
//       return;
//     }

//     setState(() => _loading = true);

//     // Persist the flag so the router redirect doesn't loop back here
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(kOnboardingComplete, true);
//     await prefs.setStringList('user_interests', _selected.toList());

//     if (mounted) {
//       // Use go() so the entire back stack is replaced — no way back to login
//       context.go('/home');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundDark,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 40),

//               // Header
//               const Text(
//                 "What are you\ninto?",
//                 style: AppTextStyles.displayLarge,
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Pick your interests and we\'ll find events you\'ll love.',
//                 style: AppTextStyles.bodyLarge,
//               ),
//               const SizedBox(height: 32),

//               // Interest grid
//               Expanded(
//                 child: GridView.builder(
//                   itemCount: _interests.length,
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 12,
//                     mainAxisSpacing: 12,
//                     childAspectRatio: 1.6,
//                   ),
//                   itemBuilder: (context, index) {
//                     final item = _interests[index];
//                     final isSelected = _selected.contains(item.label);
//                     return _InterestTile(
//                       item: item,
//                       isSelected: isSelected,
//                       onTap: () {
//                         setState(() {
//                           if (isSelected) {
//                             _selected.remove(item.label);
//                           } else {
//                             _selected.add(item.label);
//                           }
//                         });
//                       },
//                     );
//                   },
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Counter
//               Center(
//                 child: Text(
//                   _selected.isEmpty
//                       ? 'Select at least one'
//                       : '${_selected.length} selected',
//                   style: AppTextStyles.bodyMedium,
//                 ),
//               ),
//               const SizedBox(height: 12),

//               // Let's Go button
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: _loading ? null : _onLetsGo,
//                   child: _loading
//                       ? const SizedBox(
//                           width: 22,
//                           height: 22,
//                           child: CircularProgressIndicator(
//                               strokeWidth: 2, color: Colors.white),
//                         )
//                       : const Text("Let's Go!"),
//                 ),
//               ),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _InterestTile extends StatelessWidget {
//   final _InterestItem item;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _InterestTile({
//     required this.item,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? item.color.withOpacity(0.2)
//               : AppColors.backgroundCard,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: isSelected ? item.color : AppColors.divider,
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               item.icon,
//               color: isSelected ? item.color : AppColors.textTertiary,
//               size: 32,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               item.label,
//               style: TextStyle(
//                 color: isSelected ? item.color : AppColors.textSecondary,
//                 fontFamily: 'Urbanist',
//                 fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _InterestItem {
//   final String label;
//   final IconData icon;
//   final Color color;
//   const _InterestItem(this.label, this.icon, this.color);
// }

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
    {
      'label': 'Comedy',
      'icon': Icons.sentiment_very_satisfied,
      'selected': false
    },
    {'label': 'Wellness', 'icon': Icons.self_improvement, 'selected': false},
  ];

  int get _selectedCount =>
      _interests.where((i) => i['selected'] == true).length;

  List<String> get _selectedLabels => _interests
      .where((i) => i['selected'] == true)
      .map((i) => i['label'] as String)
      .toList();

  Future<void> _onLetsGo() async {
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;

      // 1. Save to SharedPreferences — router uses this flag
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      await prefs.setStringList('user_interests', _selectedLabels);

      // 2. Save to Firestore — use set with merge:true
      // so it works whether doc exists or not
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'displayName':
              user.displayName ?? user.email?.split('@').first ?? 'Guest',
          'email': user.email ?? 'guest@local.app',
          'photoUrl': user.photoURL ?? '',
          'interests': _selectedLabels,
          'onboardingComplete': true,
          'savedEvents': [],
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print('Interests saved to Firestore: $_selectedLabels');
      } else {
        print('No Firebase user found — interests saved locally only');
      }

      if (mounted) context.go(AppRoutes.home);
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
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Your Interests')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What do you love?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Pick at least 2 to personalise your feed',
                style: TextStyle(color: Colors.grey)),
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
                    onTap: () => setState(
                        () => _interests[index]['selected'] = !isSelected),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceVariant,
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
                          Icon(item['icon'] as IconData,
                              size: 32,
                              color: isSelected ? Colors.white : null),
                          const SizedBox(height: 8),
                          Text(item['label'] as String,
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
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: Text(_selectedCount >= 2
                          ? "Let's Go! 🎉"
                          : 'Pick at least 2'),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
