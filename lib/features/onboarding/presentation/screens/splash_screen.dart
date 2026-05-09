import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../routing/app_router.dart';
import '../../../events/presentation/providers/saved_events_provider.dart';
import '../../../events/presentation/providers/rsvp_provider.dart';

// ← Changed to ConsumerStatefulWidget so we can access ref
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      final prefs = await SharedPreferences.getInstance();
      final onboardingDone = prefs.getBool('onboarding_complete') ?? false;

      if (user != null && onboardingDone) {
        // ── Sync saved + RSVP from Firestore before going home ──────────
        await ref.read(savedEventsProvider.notifier).syncFromFirestore();
        await ref.read(rsvpProvider.notifier).syncFromFirestore();
        // ────────────────────────────────────────────────────────────────
        if (mounted) context.go(AppRoutes.home);
      } else if (user != null && !onboardingDone) {
        if (mounted) context.go(AppRoutes.interestPicker);
      } else {
        if (mounted) context.go(AppRoutes.onboarding);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on,
                size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const Text('Local Event Explorer',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Discover events near you',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}