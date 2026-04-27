import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';

// Key used by app_router.dart redirect to know onboarding is done
const String kOnboardingComplete = 'onboarding_complete';

class InterestPickerScreen extends StatefulWidget {
  const InterestPickerScreen({super.key});

  @override
  State<InterestPickerScreen> createState() => _InterestPickerScreenState();
}

class _InterestPickerScreenState extends State<InterestPickerScreen> {
  final Set<String> _selected = {};
  bool _loading = false;

  final List<_InterestItem> _interests = const [
    _InterestItem('Music', Icons.music_note_rounded, AppColors.catMusic),
    _InterestItem('Tech', Icons.computer_rounded, AppColors.catTech),
    _InterestItem('Art', Icons.palette_rounded, AppColors.catArt),
    _InterestItem('Sports', Icons.sports_soccer_rounded, AppColors.catSports),
    _InterestItem('Food', Icons.restaurant_rounded, AppColors.catFood),
    _InterestItem(
        'Business', Icons.business_center_rounded, AppColors.catBusiness),
    _InterestItem('Gaming', Icons.sports_esports_rounded, AppColors.primary),
    _InterestItem('Travel', Icons.flight_rounded, AppColors.accent),
    _InterestItem('Health', Icons.favorite_rounded, AppColors.success),
    _InterestItem(
        'Comedy', Icons.sentiment_very_satisfied_rounded, AppColors.warning),
  ];

  Future<void> _onLetsGo() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pick at least one interest to continue'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    // Persist the flag so the router redirect doesn't loop back here
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingComplete, true);
    await prefs.setStringList('user_interests', _selected.toList());

    if (mounted) {
      // Use go() so the entire back stack is replaced — no way back to login
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Header
              const Text(
                "What are you\ninto?",
                style: AppTextStyles.displayLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Pick your interests and we\'ll find events you\'ll love.',
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: 32),

              // Interest grid
              Expanded(
                child: GridView.builder(
                  itemCount: _interests.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                  ),
                  itemBuilder: (context, index) {
                    final item = _interests[index];
                    final isSelected = _selected.contains(item.label);
                    return _InterestTile(
                      item: item,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selected.remove(item.label);
                          } else {
                            _selected.add(item.label);
                          }
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Counter
              Center(
                child: Text(
                  _selected.isEmpty
                      ? 'Select at least one'
                      : '${_selected.length} selected',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              const SizedBox(height: 12),

              // Let's Go button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _onLetsGo,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Let's Go!"),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InterestTile extends StatelessWidget {
  final _InterestItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _InterestTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? item.color.withOpacity(0.2)
              : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? item.color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              color: isSelected ? item.color : AppColors.textTertiary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected ? item.color : AppColors.textSecondary,
                fontFamily: 'Urbanist',
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InterestItem {
  final String label;
  final IconData icon;
  final Color color;
  const _InterestItem(this.label, this.icon, this.color);
}
