// lib/features/events/presentation/providers/rsvp_provider.dart
//
// Manages RSVP'd events. Persists to both SharedPreferences (fast local
// read) and Firestore (cross-device, visible in Firebase console).
//
// RSVP'd events that have PASSED are automatically surfaced as "past events".

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/event_model.dart';
import '../../../notifications/data/notification_service.dart';

const _kRsvpKey = 'rsvp_events_json';

// ── State ──────────────────────────────────────────────────────────────────

class RsvpState {
  final List<EventModel> rsvpd;   // upcoming / current RSVP'd events
  final List<EventModel> past;    // expired RSVP'd events

  const RsvpState({required this.rsvpd, required this.past});

  factory RsvpState.empty() => const RsvpState(rsvpd: [], past: []);


  //expiring events
  List<EventModel> get expiringSoon {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    return rsvpd.where((event) {
      return event.dateTime.isAfter(now) &&
          event.dateTime.isBefore(tomorrow);
    }).toList();
  }
  /// Split a flat list into upcoming vs past by comparing dateTime to now.
  factory RsvpState.fromList(List<EventModel> all) {
    final now = DateTime.now();
    final upcoming = <EventModel>[];
    final past = <EventModel>[];
    for (final e in all) {
      // treat "day of event" as still upcoming; move to past after midnight
      if (e.dateTime.isBefore(DateTime(now.year, now.month, now.day))) {
        past.add(e);
      } else {
        upcoming.add(e);
      }
    }
    // Sort upcoming soonest first, past most-recent first
    upcoming.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    past.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return RsvpState(rsvpd: upcoming, past: past);
  }

  bool isRsvpd(String eventId) =>
      rsvpd.any((e) => e.id == eventId) || past.any((e) => e.id == eventId);
}

// ── Notifier ───────────────────────────────────────────────────────────────

class RsvpNotifier extends StateNotifier<RsvpState> {
  RsvpNotifier() : super(RsvpState.empty()) {
    _load();
  }

  // ── Persistence helpers ──────────────────────────────────────────────────

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kRsvpKey);
      if (raw == null) return;
      final List<dynamic> decoded = jsonDecode(raw);
      final events =
      decoded.map((j) => EventModel.fromJson(j as Map<String, dynamic>)).toList();
      state = RsvpState.fromList(events);
    } catch (_) {}
  }

  Future<void> _persist(List<EventModel> all) async {
    try {
      // Local
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _kRsvpKey, jsonEncode(all.map((e) => e.toJson()).toList()));

      // Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'rsvpEvents': all.map((e) => e.toJson()).toList(),
        }, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  // ── Public API ────────────────────────────────────────────────────────────

  bool isRsvpd(String eventId) => state.isRsvpd(eventId);

  Future<void> toggleRsvp(EventModel event) async {
    final all = [...state.rsvpd, ...state.past];

    if (isRsvpd(event.id)) {
      all.removeWhere((e) => e.id == event.id);

      await NotificationService().cancelEventReminder(event.id);
    } else {
      all.add(event);

      await NotificationService().scheduleEventReminder(event);
    }

    state = RsvpState.fromList(all);
    await _persist(all);
  }

  /// Call on app start if you want to also pull from Firestore
  /// (handles the case where user clears app data but still has Firestore)
  Future<void> syncFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!doc.exists) return;
      final data = doc.data();
      final raw = data?['rsvpEvents'] as List<dynamic>?;
      if (raw == null) return;
      final events =
      raw.map((j) => EventModel.fromJson(j as Map<String, dynamic>)).toList();
      state = RsvpState.fromList(events);
      // Also update local cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _kRsvpKey, jsonEncode(events.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }
}

// ── Provider ───────────────────────────────────────────────────────────────

final rsvpProvider = StateNotifierProvider<RsvpNotifier, RsvpState>(
      (ref) => RsvpNotifier(),
);

























