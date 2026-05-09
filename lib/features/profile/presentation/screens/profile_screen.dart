import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../events/data/event_model.dart';
import '../../../events/presentation/providers/saved_events_provider.dart';
import '../../../events/presentation/providers/rsvp_provider.dart';
import '../../../events/presentation/providers/theme_provider.dart'; // ← theme toggle

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_complete');
    await FirebaseAuth.instance.signOut();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = ref.watch(themeModeProvider); // ← theme state

    // Saved events — split into upcoming vs past
    final savedAll = ref.watch(savedEventsProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final savedUpcoming = savedAll.where((e) => !e.dateTime.isBefore(today)).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final savedPast = savedAll.where((e) => e.dateTime.isBefore(today)).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    // RSVP state
    final rsvpState = ref.watch(rsvpProvider);
    final rsvpdIds = {
      ...rsvpState.rsvpd.map((e) => e.id),
      ...rsvpState.past.map((e) => e.id),
    };
    final savedOnlyPast = savedPast.where((e) => !rsvpdIds.contains(e.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Profile', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.backgroundDark,
        actions: [
          // ── Dark / Light toggle ──────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  size: 18,
                  color: isDark ? Colors.amber : AppColors.primary,
                ),
                Switch.adaptive(
                  value: isDark,
                  onChanged: (_) =>
                      ref.read(themeModeProvider.notifier).toggle(),
                  activeColor: Colors.amber,
                  inactiveThumbColor: AppColors.primary,
                  inactiveTrackColor: AppColors.primary.withOpacity(0.3),
                ),
              ],
            ),
          ),
          // ── Logout icon ──────────────────────────────────
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textPrimary),
            tooltip: 'Logout',
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 16),

          // ── Avatar + name ──────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? Text(
                          _initials(user),
                          style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user?.displayName ?? user?.email?.split('@').first ?? 'Guest',
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(user?.email ?? 'Anonymous', style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Stats row ──────────────────────────────────────────────────
          Row(
            children: [
              _StatCard(
                label: 'Going',
                count: rsvpState.rsvpd.length,
                icon: Icons.event_available,
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Saved',
                count: savedUpcoming.length,
                icon: Icons.bookmark,
                color: Colors.amber,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Attended',
                count: rsvpState.past.length,
                icon: Icons.check_circle,
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── GOING section ──────────────────────────────────────────────
          _SectionHeader(
            icon: Icons.event_available,
            iconColor: Colors.green,
            title: 'Going',
            subtitle: '${rsvpState.rsvpd.length} upcoming',
          ),
          const SizedBox(height: 8),
          if (rsvpState.rsvpd.isEmpty)
            const _EmptyState(
              icon: Icons.event_available_outlined,
              message: "No upcoming RSVPs yet.\nTap \"I'm Going!\" on any event page.",
            )
          else
            ...rsvpState.rsvpd.map((e) => _EventTile(
                  event: e,
                  trailing: _dateChip(e.dateTime, Colors.green),
                  onTap: () => context.push('/event/${e.id}'),
                )),
          const SizedBox(height: 28),

          // ── SAVED section ──────────────────────────────────────────────
          _SectionHeader(
            icon: Icons.bookmark,
            iconColor: Colors.amber,
            title: 'Saved Events',
            subtitle: '${savedUpcoming.length} upcoming',
          ),
          const SizedBox(height: 8),
          if (savedUpcoming.isEmpty)
            const _EmptyState(
              icon: Icons.bookmark_outline,
              message: 'No saved events.\nTap the bookmark icon on any event to save it.',
            )
          else
            ...savedUpcoming.map((e) => _EventTile(
                  event: e,
                  trailing: _dateChip(e.dateTime, Colors.amber),
                  onTap: () => context.push('/event/${e.id}'),
                )),
          const SizedBox(height: 28),

          // ── PAST EVENTS section ────────────────────────────────────────
          if (rsvpState.past.isNotEmpty || savedOnlyPast.isNotEmpty) ...[
            _SectionHeader(
              icon: Icons.history,
              iconColor: Colors.grey,
              title: 'Past Events',
              subtitle: '${rsvpState.past.length + savedOnlyPast.length} events',
            ),
            const SizedBox(height: 8),
            ...rsvpState.past.map((e) => _EventTile(
                  event: e,
                  trailing: _badge('Attended', Colors.green),
                  muted: true,
                  onTap: () => context.push('/event/${e.id}'),
                )),
            ...savedOnlyPast.map((e) => _EventTile(
                  event: e,
                  trailing: _badge('Saved', Colors.grey),
                  muted: true,
                  onTap: () => context.push('/event/${e.id}'),
                )),
            const SizedBox(height: 28),
          ],

          // ── Logout button ──────────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () => _logout(context, ref),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _initials(User? user) {
    final name = user?.displayName ?? user?.email ?? 'G';
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  Widget _dateChip(DateTime dt, Color color) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        '${dt.day} ${months[dt.month - 1]}',
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon, required this.iconColor,
    required this.title, required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const Spacer(),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label, required this.count,
    required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text('$count',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.textTertiary),
          const SizedBox(height: 10),
          Text(message,
              style: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final EventModel event;
  final Widget trailing;
  final VoidCallback onTap;
  final bool muted;

  const _EventTile({
    required this.event, required this.trailing,
    required this.onTap, this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: muted ? 0.65 : 1.0,
      child: Card(
        color: AppColors.backgroundCard,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          onTap: onTap,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              event.imageUrl,
              width: 52, height: 52, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 52, height: 52,
                color: Colors.grey[800],
                child: const Icon(Icons.event, color: Colors.white54, size: 24),
              ),
            ),
          ),
          title: Text(event.title,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text('📍 ${event.city}',
              style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
          trailing: trailing,
        ),
      ),
    );
  }
}