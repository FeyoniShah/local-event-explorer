import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/event_model.dart';
import '../../data/event_repository.dart';

final eventRepositoryProvider = Provider((ref) => EventRepository());

// Location provider — requests permission and returns current position
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

// Home feed — all India upcoming events, nearest first
final eventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final repo = ref.read(eventRepositoryProvider);
  final position = await ref.watch(locationProvider.future);

  final events = await repo.fetchEvents(
    lat: position?.latitude,
    lng: position?.longitude,
  );

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final upcoming = events
      .where((e) =>
          e.dateTime.isAfter(today) ||
          (e.dateTime.month == now.month && e.dateTime.year == now.year))
      .toList();

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

// Search providers
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];

  final repo = ref.read(eventRepositoryProvider);
  final position = await ref.watch(locationProvider.future);

  final events = await repo.searchEvents(
    query: query.trim(),
    lat: position?.latitude,
    lng: position?.longitude,
  );

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final upcoming = events
      .where((e) =>
          e.dateTime.isAfter(today) ||
          (e.dateTime.month == now.month && e.dateTime.year == now.year))
      .toList();

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
