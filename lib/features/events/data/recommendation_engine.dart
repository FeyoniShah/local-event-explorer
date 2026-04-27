import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'event_model.dart';

class RecommendationEngine {

  /// Main method — returns events sorted by relevance score
  List<EventModel> recommend({
    required List<EventModel> events,
    required List<String> userInterests,
    required double userLat,
    required double userLng,
    int limit = 20,
  }) {
    final scored = events.map((event) {
      final score = _scoreEvent(
        event: event,
        userInterests: userInterests,
        userLat: userLat,
        userLng: userLng,
      );
      return _ScoredEvent(event: event, score: score);
    }).toList();

    // Sort descending by score
    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored.take(limit).map((e) => e.event).toList();
  }

  double _scoreEvent({
    required EventModel event,
    required List<String> userInterests,
    required double userLat,
    required double userLng,
  }) {
    double score = 0;

    // ── 1. Interest match (40 pts) ──────────────────────────
    final normalizedInterests =
        userInterests.map((i) => i.toLowerCase()).toList();
    final normalizedCategory = event.category.toLowerCase();

    if (normalizedInterests.contains(normalizedCategory)) {
      score += 40;
    } else if (_hasPartialMatch(normalizedCategory, normalizedInterests)) {
      score += 20;
    }

    // ── 2. Distance score (30 pts) ──────────────────────────
    final distanceKm = _haversineDistance(
      userLat, userLng,
      event.latitude, event.longitude,
    );

    if (distanceKm <= 2) {
      score += 30;
    } else if (distanceKm <= 5) {
      score += 25;
    } else if (distanceKm <= 10) {
      score += 20;
    } else if (distanceKm <= 20) {
      score += 12;
    } else if (distanceKm <= 50) {
      score += 6;
    }

    // ── 3. Recency score (20 pts) ───────────────────────────
    final now = DateTime.now();
    final daysUntilEvent = event.dateTime.difference(now).inDays;

    if (daysUntilEvent < 0) {
      score += 0;
    } else if (daysUntilEvent == 0) {
      score += 20;
    } else if (daysUntilEvent <= 3) {
      score += 16;
    } else if (daysUntilEvent <= 7) {
      score += 12;
    } else if (daysUntilEvent <= 14) {
      score += 8;
    } else if (daysUntilEvent <= 30) {
      score += 4;
    }

    // ── 4. Popularity score (10 pts) ────────────────────────
    if (event.attendeeCount >= 500) {
      score += 10;
    } else if (event.attendeeCount >= 200) {
      score += 8;
    } else if (event.attendeeCount >= 100) {
      score += 6;
    } else if (event.attendeeCount >= 50) {
      score += 4;
    } else if (event.attendeeCount >= 10) {
      score += 2;
    }

    return score;
  }

  bool _hasPartialMatch(String category, List<String> interests) {
    final synonyms = {
      'tech': ['technology', 'coding', 'programming', 'software'],
      'music': ['concert', 'band', 'festival', 'live music'],
      'art': ['exhibition', 'gallery', 'design', 'craft'],
      'food': ['culinary', 'dining', 'restaurant', 'tasting'],
      'sports': ['fitness', 'game', 'match', 'tournament'],
      'business': ['startup', 'networking', 'entrepreneurship'],
    };

    for (final interest in interests) {
      if (synonyms[interest]?.contains(category) ?? false) return true;
      if (synonyms[category]?.contains(interest) ?? false) return true;
    }
    return false;
  }

  /// Haversine formula — accurate distance in km between two coordinates
  double _haversineDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) *
            cos(_toRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180;
}

class _ScoredEvent {
  final EventModel event;
  final double score;
  _ScoredEvent({required this.event, required this.score});
}

final recommendationEngineProvider =
    Provider<RecommendationEngine>((ref) => RecommendationEngine());