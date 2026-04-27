import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/event_model.dart';
import '../../data/dummy_events.dart';
import '../../data/recommendation_engine.dart';

// User's current position
final userLocationProvider = FutureProvider<Position>((ref) async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services disabled');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permission permanently denied');
  }

  return await Geolocator.getCurrentPosition();
});

// User interests — hardcoded default, later read from Firestore
final userInterestsProvider = StateProvider<List<String>>((ref) {
  return ['Music', 'Tech', 'Art'];
});

// All events from dummy data
final allEventsProvider = Provider<List<EventModel>>((ref) {
  return dummyEvents;
});

// AI recommended events — sorted by score
final recommendedEventsProvider = Provider<List<EventModel>>((ref) {
  final events = ref.watch(allEventsProvider);
  final interests = ref.watch(userInterestsProvider);
  final engine = ref.watch(recommendationEngineProvider);
  final locationAsync = ref.watch(userLocationProvider);

  // Nagpur coordinates as fallback
  const fallbackLat = 21.1458;
  const fallbackLng = 79.0882;

  return locationAsync.when(
    data: (position) => engine.recommend(
      events: events,
      userInterests: interests,
      userLat: position.latitude,
      userLng: position.longitude,
    ),
    loading: () => engine.recommend(
      events: events,
      userInterests: interests,
      userLat: fallbackLat,
      userLng: fallbackLng,
    ),
    error: (_, __) => engine.recommend(
      events: events,
      userInterests: interests,
      userLat: fallbackLat,
      userLng: fallbackLng,
    ),
  );
});