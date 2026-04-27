// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../../../core/theme/app_theme.dart';

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});

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
//               const SizedBox(height: 48),

//               // Header icon
//               Container(
//                 width: 64,
//                 height: 64,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [AppColors.primary, AppColors.accent],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(18),
//                 ),
//                 child: const Icon(
//                   Icons.location_on_rounded,
//                   color: Colors.white,
//                   size: 36,
//                 ),
//               ),
//               const SizedBox(height: 28),

//               const Text('Welcome Back!', style: AppTextStyles.displayLarge),
//               const SizedBox(height: 8),
//               const Text(
//                 'Sign in to discover local events',
//                 style: AppTextStyles.bodyLarge,
//               ),
//               const SizedBox(height: 48),

//               // ── Google button ────────────────────────────────────────────
//               // Real Google Sign-In requires Firebase + a web OAuth client ID
//               // in web/index.html. Since Firebase is not wired for web yet,
//               // we navigate directly (demo / mobile-only mode).
//               _SocialButton(
//                 iconWidget: const Icon(Icons.g_mobiledata_rounded,
//                     color: Colors.redAccent, size: 22),
//                 label: 'Continue with Google',
//                 onTap: () => context.go('/interest-picker'),
//               ),
//               const SizedBox(height: 16),

//               _SocialButton(
//                 iconWidget: const Icon(Icons.email_outlined,
//                     color: AppColors.primary, size: 20),
//                 label: 'Continue with Email',
//                 onTap: () => _showEmailDialog(context),
//               ),
//               const SizedBox(height: 16),

//               _SocialButton(
//                 iconWidget: const Icon(Icons.phone_rounded,
//                     color: AppColors.success, size: 20),
//                 label: 'Continue with Phone',
//                 onTap: () => context.go('/interest-picker'),
//               ),

//               const Spacer(),

//               Center(
//                 child: Text(
//                   'By continuing you agree to our Terms & Privacy Policy',
//                   style: AppTextStyles.labelSmall,
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showEmailDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: AppColors.backgroundCard,
//         title: const Text('Sign In', style: AppTextStyles.headlineMedium),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               style: const TextStyle(
//                   color: AppColors.textPrimary, fontFamily: 'Urbanist'),
//               decoration: const InputDecoration(
//                 hintText: 'Email address',
//                 prefixIcon:
//                     Icon(Icons.email_outlined, color: AppColors.textTertiary),
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               obscureText: true,
//               style: const TextStyle(
//                   color: AppColors.textPrimary, fontFamily: 'Urbanist'),
//               decoration: const InputDecoration(
//                 hintText: 'Password',
//                 prefixIcon:
//                     Icon(Icons.lock_outline, color: AppColors.textTertiary),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Cancel',
//                 style: TextStyle(color: AppColors.textTertiary)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(ctx);
//               // Navigate to interest-picker after "sign in"
//               context.go('/interest-picker');
//             },
//             child: const Text('Sign In'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SocialButton extends StatelessWidget {
//   final Widget iconWidget;
//   final String label;
//   final VoidCallback onTap;

//   const _SocialButton({
//     required this.iconWidget,
//     required this.label,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 56,
//       child: OutlinedButton(
//         onPressed: onTap,
//         style: OutlinedButton.styleFrom(
//           side: const BorderSide(color: AppColors.divider),
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//           backgroundColor: AppColors.backgroundCard,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             iconWidget,
//             const SizedBox(width: 12),
//             Text(
//               label,
//               style: const TextStyle(
//                 color: AppColors.textPrimary,
//                 fontFamily: 'Urbanist',
//                 fontWeight: FontWeight.w600,
//                 fontSize: 15,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../routing/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  // Anonymous sign-in for Google/Phone demo buttons
  Future<void> _signInAnonymously() async {
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.signInAnonymously();
      await _ensureUserDoc(cred.user!,
          displayName: 'Guest', email: 'guest@local.app');
      if (mounted) context.go(AppRoutes.interestPicker);
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Sign-in failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Email sign-in or auto-create account
  Future<void> _signInWithEmail(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _showError('Enter email and password');
      return;
    }
    setState(() => _loading = true);
    try {
      UserCredential cred;
      try {
        cred = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' ||
            e.code == 'invalid-credential' ||
            e.code == 'INVALID_LOGIN_CREDENTIALS') {
          cred = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);
        } else {
          rethrow;
        }
      }
      final name = email.split('@').first;
      await _ensureUserDoc(cred.user!, displayName: name, email: email);
      if (mounted) context.go(AppRoutes.interestPicker);
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Sign-in failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Save user to Firestore on first login only
  Future<void> _ensureUserDoc(User user,
      {required String displayName, required String email}) async {
    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snap = await doc.get();
    if (!snap.exists) {
      await doc.set({
        'uid': user.uid,
        'displayName': displayName,
        'email': email,
        'photoUrl': user.photoURL ?? '',
        'interests': <String>[],
        'savedEvents': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  void _showEmailDialog() {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text('Sign In / Register',
            style: AppTextStyles.headlineMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontFamily: 'Urbanist'),
              decoration: const InputDecoration(
                hintText: 'Email address',
                prefixIcon:
                    Icon(Icons.email_outlined, color: AppColors.textTertiary),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontFamily: 'Urbanist'),
              decoration: const InputDecoration(
                hintText: 'Password (min 6 chars)',
                prefixIcon:
                    Icon(Icons.lock_outline, color: AppColors.textTertiary),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "New user? We'll create your account automatically.",
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _signInWithEmail(emailCtrl.text.trim(), passCtrl.text.trim());
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
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
              const SizedBox(height: 48),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.location_on_rounded,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(height: 28),
              const Text('Welcome Back!', style: AppTextStyles.displayLarge),
              const SizedBox(height: 8),
              const Text('Sign in to discover local events',
                  style: AppTextStyles.bodyLarge),
              const SizedBox(height: 48),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else ...[
                _SocialButton(
                  icon: Icons.g_mobiledata_rounded,
                  iconColor: Colors.redAccent,
                  label: 'Continue with Google',
                  onTap: _signInAnonymously,
                ),
                const SizedBox(height: 16),
                _SocialButton(
                  icon: Icons.email_outlined,
                  iconColor: AppColors.primary,
                  label: 'Continue with Email',
                  onTap: _showEmailDialog,
                ),
                const SizedBox(height: 16),
                _SocialButton(
                  icon: Icons.phone_rounded,
                  iconColor: AppColors.success,
                  label: 'Continue with Phone',
                  onTap: _signInAnonymously,
                ),
              ],
              const Spacer(),
              const Center(
                child: Text(
                  'By continuing you agree to our Terms & Privacy Policy',
                  style: AppTextStyles.labelSmall,
                  textAlign: TextAlign.center,
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

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.divider),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: AppColors.backgroundCard,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                )),
          ],
        ),
      ),
    );
  }
}
