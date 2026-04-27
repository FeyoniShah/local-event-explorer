import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/presentation/screens/splash_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/interest_picker_screen.dart';
import '../features/auth/data/auth_service.dart';
import '../features/events/presentation/screens/home_screen.dart';
import '../features/events/presentation/screens/event_detail_screen.dart';
import '../features/events/presentation/screens/search_screen.dart';
import '../features/map/presentation/screens/map_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../shared/widgets/main_shell.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const interestPicker = '/interest-picker';
  static const home = '/home';
  static const eventDetail = '/event/:id';
  static const search = '/search';
  static const map = '/map';
  static const profile = '/profile';
  static const savedEvents = '/saved';
  static const chatPlaceholder = '/chat/:eventId';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  // Listen to auth state changes so router rebuilds on login/logout
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: _AuthStateNotifier(ref),
    routes: [
      // ── Splash ──────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Onboarding ──────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── Auth ────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.interestPicker,
        builder: (context, state) => const InterestPickerScreen(),
      ),

      // ── Main shell with bottom nav ───────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.search,
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: AppRoutes.map,
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ── Event detail (outside shell — full screen) ───────
      GoRoute(
        path: AppRoutes.eventDetail,
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return EventDetailScreen(eventId: eventId);
        },
      ),

      // ── Chat placeholder ─────────────────────────────────
      GoRoute(
        path: AppRoutes.chatPlaceholder,
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return ChatPlaceholderScreen(eventId: eventId);
        },
      ),
    ],

    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;

      final publicRoutes = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.interestPicker,
      ];
      final isPublicRoute = publicRoutes.contains(state.matchedLocation);

      // Not logged in and trying to access a protected route
      if (!isLoggedIn && !isPublicRoute) return AppRoutes.login;

      // Logged in and trying to access login — send to home
      if (isLoggedIn && state.matchedLocation == AppRoutes.login) {
        return AppRoutes.home;
      }

      return null;
    },
  );
});

// Notifier that tells GoRouter to re-evaluate redirect when auth changes
class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}

// Chat placeholder screen
class ChatPlaceholderScreen extends StatelessWidget {
  final String eventId;
  const ChatPlaceholderScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Chat')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 64,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const Text(
              'Group Chat',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming soon — stay tuned!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}