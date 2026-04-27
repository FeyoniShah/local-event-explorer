import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/event_model.dart';
import '../../data/event_repository.dart';

final eventRepositoryProvider = Provider((ref) => EventRepository());

// ─── Location ────────────────────────────────────────────────────────────────
final locationProvider = FutureProvider<Position?>((ref) async {
  try {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    }
    return null;
  } catch (_) {
    return null;
  }
});

// ─── Home Feed ───────────────────────────────────────────────────────────────
// Fetches ALL India upcoming events, nearest first
final eventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final repo = ref.read(eventRepositoryProvider);
  final position = await ref.watch(locationProvider.future);

  final events = await repo.fetchEvents(
    lat: position?.latitude,
    lng: position?.longitude,
  );

  // Filter: only upcoming (from start of today)
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final upcoming = events
      .where((e) => e.dateTime.isAfter(today) ||
          (e.dateTime.month == now.month && e.dateTime.year == now.year))
      .toList();

  // Sort nearest first if we have location
  if (position != null && upcoming.isNotEmpty) {
    upcoming.sort((a, b) {
      final dA = Geolocator.distanceBetween(
          position.latitude, position.longitude, a.latitude, a.longitude);
      final dB = Geolocator.distanceBetween(
          position.latitude, position.longitude, b.latitude, b.longitude);
      return dA.compareTo(dB);
    });
  }

  return upcoming;
});

// ─── Search ──────────────────────────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];

  final repo = ref.read(eventRepositoryProvider);
  final position = await ref.watch(locationProvider.future);

  // Use the actual query typed by user
  final events = await repo.searchEvents(
    query: query.trim(),
    lat: position?.latitude,
    lng: position?.longitude,
  );

  // Filter upcoming only
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final upcoming = events
      .where((e) => e.dateTime.isAfter(today) ||
          (e.dateTime.month == now.month && e.dateTime.year == now.year))
      .toList();

  // Sort nearest first
  if (position != null && upcoming.isNotEmpty) {
    upcoming.sort((a, b) {
      final dA = Geolocator.distanceBetween(
          position.latitude, position.longitude, a.latitude, a.longitude);
      final dB = Geolocator.distanceBetween(
          position.latitude, position.longitude, b.latitude, b.longitude);
      return dA.compareTo(dB);
    });
  }

  return upcoming;
});