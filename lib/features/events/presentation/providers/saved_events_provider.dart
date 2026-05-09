import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/event_model.dart';

const _kSavedKey = 'saved_events_json';

class SavedEventsNotifier extends StateNotifier<List<EventModel>> {
  SavedEventsNotifier() : super([]) {
    _load();
  }

  // ── Load from SharedPreferences on startup ─────────────────────────────
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kSavedKey);
      if (raw != null) {
        final List<dynamic> decoded = jsonDecode(raw);
        state = decoded
            .map((j) => EventModel.fromJson(j as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
  }

  // ── Persist to SharedPreferences + Firestore ───────────────────────────
  Future<void> _persist() async {
    try {
      // Local — instant
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _kSavedKey, jsonEncode(state.map((e) => e.toJson()).toList()));

      // Firestore — cross device
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'savedEvents': state.map((e) => e.toJson()).toList(),
        }, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  // ── Public API ─────────────────────────────────────────────────────────
  Future<void> toggleSave(EventModel event) async {
    final isSaved = state.any((e) => e.id == event.id);
    if (isSaved) {
      state = state.where((e) => e.id != event.id).toList();
    } else {
      state = [...state, event];
    }
    await _persist();
  }

  bool isSaved(String eventId) => state.any((e) => e.id == eventId);

  /// Call on login to sync saved events from Firestore
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
      final raw = data?['savedEvents'] as List<dynamic>?;
      if (raw == null) return;

      state = raw
          .map((j) => EventModel.fromJson(j as Map<String, dynamic>))
          .toList();

      // Update local cache too
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _kSavedKey, jsonEncode(state.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }
}

final savedEventsProvider =
    StateNotifierProvider<SavedEventsNotifier, List<EventModel>>(
        (ref) => SavedEventsNotifier());