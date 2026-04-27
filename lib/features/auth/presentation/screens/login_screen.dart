import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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

              // Header icon
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
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 28),

              const Text('Welcome Back!', style: AppTextStyles.displayLarge),
              const SizedBox(height: 8),
              const Text(
                'Sign in to discover local events',
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: 48),

              // ── Google button ────────────────────────────────────────────
              // Real Google Sign-In requires Firebase + a web OAuth client ID
              // in web/index.html. Since Firebase is not wired for web yet,
              // we navigate directly (demo / mobile-only mode).
              _SocialButton(
                iconWidget: const Icon(Icons.g_mobiledata_rounded,
                    color: Colors.redAccent, size: 22),
                label: 'Continue with Google',
                onTap: () => context.go('/interest-picker'),
              ),
              const SizedBox(height: 16),

              _SocialButton(
                iconWidget: const Icon(Icons.email_outlined,
                    color: AppColors.primary, size: 20),
                label: 'Continue with Email',
                onTap: () => _showEmailDialog(context),
              ),
              const SizedBox(height: 16),

              _SocialButton(
                iconWidget: const Icon(Icons.phone_rounded,
                    color: AppColors.success, size: 20),
                label: 'Continue with Phone',
                onTap: () => context.go('/interest-picker'),
              ),

              const Spacer(),

              Center(
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

  void _showEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text('Sign In', style: AppTextStyles.headlineMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
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
              obscureText: true,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontFamily: 'Urbanist'),
              decoration: const InputDecoration(
                hintText: 'Password',
                prefixIcon:
                    Icon(Icons.lock_outline, color: AppColors.textTertiary),
              ),
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
              // Navigate to interest-picker after "sign in"
              context.go('/interest-picker');
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.iconWidget,
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
            iconWidget,
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
