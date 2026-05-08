// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../../../routing/app_router.dart';
// import '../../../events/data/dummy_events.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Profile")),
//       body: ListView(
//         children: [
//           const SizedBox(height: 24),

//           // Avatar + name
//           Center(
//             child: Column(
//               children: [
//                 CircleAvatar(
//                   radius: 48,
//                   backgroundColor: Theme.of(context).colorScheme.primary,
//                   child: const Icon(Icons.person, size: 48, color: Colors.white),
//                 ),
//                 const SizedBox(height: 12),
//                 const Text("Sejal",
//                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//                 const Text("sejal@example.com",
//                     style: TextStyle(color: Colors.grey)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 32),

//           // Interests
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: Text("My Interests",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//           ),
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Wrap(
//               spacing: 8,
//               children: ["Music", "Tech", "Food"]
//                   .map((i) => Chip(label: Text(i)))
//                   .toList(),
//             ),
//           ),

//           const SizedBox(height: 24),
//           const Divider(),

//           // Saved Events
//           ListTile(
//             leading: const Icon(Icons.bookmark_outline),
//             title: const Text("Saved Events"),
//             trailing: const Icon(Icons.chevron_right),
//             onTap: () {
//               // Show saved events in a bottom sheet
//               showModalBottomSheet(
//                 context: context,
//                 isScrollControlled: true,
//                 shape: const RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.vertical(top: Radius.circular(20))),
//                 builder: (_) => DraggableScrollableSheet(
//                   initialChildSize: 0.6,
//                   maxChildSize: 0.9,
//                   minChildSize: 0.4,
//                   expand: false,
//                   builder: (_, controller) => Column(
//                     children: [
//                       const SizedBox(height: 12),
//                       Container(
//                         width: 40,
//                         height: 4,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[400],
//                           borderRadius: BorderRadius.circular(2),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       const Text("Saved Events",
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 8),
//                       Expanded(
//                         child: dummyEvents.isEmpty
//                             ? const Center(
//                                 child: Text("No saved events yet!",
//                                     style: TextStyle(color: Colors.grey)))
//                             : ListView.builder(
//                                 controller: controller,
//                                 itemCount: dummyEvents.length,
//                                 itemBuilder: (context, index) {
//                                   final event = dummyEvents[index];
//                                   return ListTile(
//                                     leading: ClipRRect(
//                                       borderRadius: BorderRadius.circular(8),
//                                       child: Image.network(
//                                         event.imageUrl,
//                                         width: 50,
//                                         height: 50,
//                                         fit: BoxFit.cover,
//                                         errorBuilder: (_, __, ___) =>
//                                             Container(
//                                                 width: 50,
//                                                 height: 50,
//                                                 color: Colors.grey[800],
//                                                 child: const Icon(Icons.image)),
//                                       ),
//                                     ),
//                                     title: Text(event.title),
//                                     subtitle: Text(event.venue),
//                                     trailing: Icon(
//                                       Icons.bookmark,
//                                       color: Theme.of(context).colorScheme.primary,
//                                     ),
//                                     onTap: () {
//                                       Navigator.pop(context);
//                                       context.push('/event/${event.id}');
//                                     },
//                                   );
//                                 },
//                               ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),

//           // Past Events
//           ListTile(
//             leading: const Icon(Icons.history),
//             title: const Text("Past Events"),
//             trailing: const Icon(Icons.chevron_right),
//             onTap: () {
//               showModalBottomSheet(
//                 context: context,
//                 shape: const RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.vertical(top: Radius.circular(20))),
//                 builder: (_) => Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Icon(Icons.history, size: 48, color: Colors.grey),
//                       const SizedBox(height: 12),
//                       const Text("Past Events",
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 8),
//                       const Text("Events you attended will appear here!",
//                           style: TextStyle(color: Colors.grey),
//                           textAlign: TextAlign.center),
//                       const SizedBox(height: 24),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () => Navigator.pop(context),
//                           child: const Text("Close"),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),

//           // Settings
//           ListTile(
//             leading: const Icon(Icons.settings_outlined),
//             title: const Text("Settings"),
//             trailing: const Icon(Icons.chevron_right),
//             onTap: () {
//               showModalBottomSheet(
//                 context: context,
//                 shape: const RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.vertical(top: Radius.circular(20))),
//                 builder: (_) => Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text("Settings",
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 16),
//                       SwitchListTile(
//                         title: const Text("Push Notifications"),
//                         subtitle: const Text("Get event reminders"),
//                         value: true,
//                         onChanged: (_) {},
//                         contentPadding: EdgeInsets.zero,
//                       ),
//                       SwitchListTile(
//                         title: const Text("Location Access"),
//                         subtitle: const Text("Find events near you"),
//                         value: true,
//                         onChanged: (_) {},
//                         contentPadding: EdgeInsets.zero,
//                       ),
//                       const SizedBox(height: 16),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () => Navigator.pop(context),
//                           child: const Text("Done"),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),

//           const Divider(),

//           // Logout
//           ListTile(
//             leading: const Icon(Icons.logout, color: Colors.red),
//             title: const Text("Log Out",
//                 style: TextStyle(color: Colors.red)),
//             onTap: () {
//               showDialog(
//                 context: context,
//                 builder: (_) => AlertDialog(
//                   title: const Text("Log Out"),
//                   content: const Text("Are you sure you want to log out?"),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text("Cancel"),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         context.go(AppRoutes.splash);
//                       },
//                       child: const Text("Log Out",
//                           style: TextStyle(color: Colors.red)),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 32),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../routing/app_router.dart';
import '../../../events/presentation/providers/saved_events_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final savedEvents = ref.watch(savedEventsProvider);

    // Read display name — anonymous users get 'Guest'
    final displayName = (user?.displayName?.isNotEmpty == true)
        ? user!.displayName!
        : (user?.email?.split('@').first ?? 'Guest');
    final email = user?.email ?? 'guest@local.app';
    final photoUrl = user?.photoURL;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          const SizedBox(height: 24),

          // ── Avatar + name ──────────────────────────────────
          Center(
            child: Column(
              children: [
                // Photo or initials
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? Text(
                          displayName[0].toUpperCase(),
                          style: const TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(displayName,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                Text(email, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── Interests from Firestore ───────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('My Interests',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 8),
          FutureBuilder<DocumentSnapshot>(
            future: user != null
                ? FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get()
                : null,
            builder: (context, snapshot) {
              List<String> interests = [];
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                interests = List<String>.from(data?['interests'] ?? []);
              }
              if (interests.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('No interests selected yet',
                      style: TextStyle(color: Colors.grey)),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: interests.map((i) => Chip(label: Text(i))).toList(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          const Divider(),

          // ── Saved Events ───────────────────────────────────
          ListTile(
            leading: const Icon(Icons.bookmark_outline),
            title: Text('Saved Events (${savedEvents.length})'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                builder: (_) => DraggableScrollableSheet(
                  initialChildSize: 0.6,
                  maxChildSize: 0.9,
                  minChildSize: 0.4,
                  expand: false,
                  builder: (_, controller) => Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Saved Events',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: savedEvents.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.bookmark_border,
                                        size: 60, color: Colors.grey),
                                    SizedBox(height: 12),
                                    Text('No saved events yet!',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 16)),
                                    SizedBox(height: 4),
                                    Text('Save events to see them here',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: controller,
                                itemCount: savedEvents.length,
                                itemBuilder: (context, index) {
                                  final event = savedEvents[index];
                                  return ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        event.imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey[800],
                                          child: const Icon(Icons.image),
                                        ),
                                      ),
                                    ),
                                    title: Text(event.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    subtitle: Text(event.venue,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    trailing: Icon(
                                      Icons.bookmark,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      context.push('/event/${event.id}');
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Past Events ────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Past Events'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('Past Events',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Events you attended will appear here!',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Settings ───────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Settings',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Push Notifications'),
                        subtitle: const Text('Get event reminders'),
                        value: true,
                        onChanged: (_) {},
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: const Text('Location Access'),
                        subtitle: const Text('Find events near you'),
                        value: true,
                        onChanged: (_) {},
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const Divider(),

          // ── Logout ─────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log Out', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Log Out'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          context.go('/');
                        }
                        // Proper Firebase sign out
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) context.go(AppRoutes.login);
                        // Router auth guard redirects to login automatically
                      },
                      child: const Text('Log Out',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
