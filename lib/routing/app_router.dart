// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../features/onboarding/presentation/screens/splash_screen.dart';
// import '../features/onboarding/presentation/screens/onboarding_screen.dart';
// import '../features/auth/presentation/screens/login_screen.dart';
// import '../features/auth/presentation/screens/interest_picker_screen.dart';
// import '../features/events/presentation/screens/home_screen.dart';
// import '../features/events/presentation/screens/event_detail_screen.dart';
// import '../features/events/presentation/screens/search_screen.dart';
// import '../features/map/presentation/screens/map_screen.dart';
// import '../features/profile/presentation/screens/profile_screen.dart';
// import '../shared/widgets/main_shell.dart';

// // Route name constants — use these everywhere, never raw strings
// class AppRoutes {
//   static const splash = '/';
//   static const onboarding = '/onboarding';
//   static const login = '/login';
//   static const interestPicker = '/interest-picker';
//   static const home = '/home';
//   static const eventDetail = '/event/:id';
//   static const search = '/search';
//   static const map = '/map';
//   static const profile = '/profile';
//   static const chatPlaceholder = '/chat/:eventId';
// }

// // Routes that are part of the onboarding / auth flow.
// // The redirect will NEVER bounce these back — prevents the loop.
// const _authRoutes = {
//   AppRoutes.splash,
//   AppRoutes.onboarding,
//   AppRoutes.login,
//   AppRoutes.interestPicker,
// };

// final appRouterProvider = Provider<GoRouter>((ref) {
//   return GoRouter(
//     initialLocation: AppRoutes.splash,
//     debugLogDiagnostics: true,

//     // ── Redirect guard ────────────────────────────────────────────────────
//     // Only redirects when user tries to reach a protected route (/home, /search,
//     // /map, /profile, /event/:id) without having completed onboarding.
//     // Auth-flow routes (/login, /interest-picker, /splash, /onboarding) are
//     // always allowed through — this is what prevented the loop before.
//     redirect: (context, state) async {
//       final location = state.matchedLocation;

//       // Always allow auth-flow routes through — no redirect
//       if (_authRoutes.contains(location)) return null;

//       // For protected routes, check if onboarding is complete
//       final prefs = await SharedPreferences.getInstance();
//       final onboardingDone = prefs.getBool(kOnboardingComplete) ?? false;

//       if (!onboardingDone) {
//         // Not onboarded → send to login
//         return AppRoutes.login;
//       }

//       // Onboarding complete → allow through
//       return null;
//     },

//     routes: [
//       // ── Splash ──────────────────────────────────────────────────────────
//       GoRoute(
//         path: AppRoutes.splash,
//         builder: (context, state) => const SplashScreen(),
//       ),

//       // ── Onboarding ──────────────────────────────────────────────────────
//       GoRoute(
//         path: AppRoutes.onboarding,
//         builder: (context, state) => const OnboardingScreen(),
//       ),

//       // ── Auth ────────────────────────────────────────────────────────────
//       GoRoute(
//         path: AppRoutes.login,
//         builder: (context, state) => const LoginScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.interestPicker,
//         builder: (context, state) => const InterestPickerScreen(),
//       ),

//       // ── Main shell with bottom nav ───────────────────────────────────────
//       ShellRoute(
//         builder: (context, state, child) => MainShell(child: child),
//         routes: [
//           GoRoute(
//             path: AppRoutes.home,
//             builder: (context, state) => const HomeScreen(),
//           ),
//           GoRoute(
//             path: AppRoutes.search,
//             builder: (context, state) => const SearchScreen(),
//           ),
//           GoRoute(
//             path: AppRoutes.map,
//             builder: (context, state) => const MapScreen(),
//           ),
//           GoRoute(
//             path: AppRoutes.profile,
//             builder: (context, state) => const ProfileScreen(),
//           ),
//         ],
//       ),

//       // ── Event detail (outside shell — full screen) ───────────────────────
//       GoRoute(
//         path: AppRoutes.eventDetail,
//         builder: (context, state) {
//           final eventId = state.pathParameters['id']!;
//           return EventDetailScreen(eventId: eventId);
//         },
//       ),

//       // ── Chat placeholder ─────────────────────────────────────────────────
//       GoRoute(
//         path: AppRoutes.chatPlaceholder,
//         builder: (context, state) {
//           final eventId = state.pathParameters['eventId']!;
//           return ChatPlaceholderScreen(eventId: eventId);
//         },
//       ),
//     ],
//   );
// });

// // ── Chat placeholder screen ──────────────────────────────────────────────────
// class ChatPlaceholderScreen extends StatelessWidget {
//   final String eventId;
//   const ChatPlaceholderScreen({super.key, required this.eventId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Event Chat')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.chat_bubble_outline,
//                 size: 64, color: Theme.of(context).colorScheme.primary),
//             const SizedBox(height: 16),
//             const Text('Group Chat',
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             const Text('Coming soon — stay tuned!',
//                 style: TextStyle(color: Colors.grey)),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/onboarding/presentation/screens/splash_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/interest_picker_screen.dart';
import '../features/events/presentation/screens/home_screen.dart';
import '../features/events/presentation/screens/event_detail_screen.dart';
import '../features/events/presentation/screens/search_screen.dart';
import '../features/map/presentation/screens/map_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../shared/widgets/main_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

// Stream provider for Firebase auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: _AuthNotifier(ref),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.interestPicker,
        builder: (context, state) => const InterestPickerScreen(),
      ),
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
      GoRoute(
        path: AppRoutes.eventDetail,
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return EventDetailScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: AppRoutes.chatPlaceholder,
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return ChatPlaceholderScreen(eventId: eventId);
        },
      ),
    ],
    redirect: (context, state) async {
      final isLoading = authState.isLoading;
      if (isLoading) return null;

      final isLoggedIn = authState.valueOrNull != null;
      final loc = state.matchedLocation;

      const publicRoutes = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.interestPicker,
      ];
      final isPublic = publicRoutes.contains(loc);

      // Not logged in trying to access protected route
      if (!isLoggedIn && !isPublic) return AppRoutes.login;

      // Logged in trying to access login — check onboarding first
      if (isLoggedIn && loc == AppRoutes.login) {
        final prefs = await SharedPreferences.getInstance();
        final onboardingDone = prefs.getBool('onboarding_complete') ?? false;
        if (!onboardingDone) return AppRoutes.interestPicker;
        return AppRoutes.home;
      }

      return null;
    },
  );
});

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}

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
                size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const Text('Group Chat',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Coming soon — stay tuned!',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
