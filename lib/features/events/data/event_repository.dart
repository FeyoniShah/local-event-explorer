import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'event_model.dart';

class EventRepository {
  static const String _rapidApiKey = '7b0e25b9f5msh90f259f408094c2p19a4bfjsnd2676afa04b2';
  static const String _rapidApiHost = 'real-time-events-search.p.rapidapi.com';

  static const Map<String, List<double>> _cityCoords = {
    'Pune': [18.5204, 73.8567],
    'Mumbai': [19.0760, 72.8777],
    'Delhi': [28.6139, 77.2090],
    'Bangalore': [12.9716, 77.5946],
    'Hyderabad': [17.3850, 78.4867],
    'Chennai': [13.0827, 80.2707],
    'Kolkata': [22.5726, 88.3639],
    'Ahmedabad': [23.0225, 72.5714],
    'Jaipur': [26.9124, 75.7873],
    'Goa': [15.2993, 74.1240],
    'Nashik': [19.9975, 73.7898],
    'Nagpur': [21.1458, 79.0882],
    'Surat': [21.1702, 72.8311],
    'Lucknow': [26.8467, 80.9462],
    'Chandigarh': [30.7333, 76.7794],
  };

  // Home feed: all India upcoming events
  Future<List<EventModel>> fetchEvents({double? lat, double? lng}) async {
    return _callApi('events in India', lat, lng);
  }

  // Search: use exact query from user
  Future<List<EventModel>> searchEvents({
    required String query,
    double? lat,
    double? lng,
  }) async {
    final q = query.toLowerCase().contains('india') ? query : '$query India';
    return _callApi(q, lat, lng);
  }

  Future<List<EventModel>> _callApi(
      String query, double? lat, double? lng) async {
    try {
      final uri = Uri.https(_rapidApiHost, '/search-events', {
        'query': query,
        'date': 'month',
        'is_virtual': 'false',
        'start': '0',
      });

      final response = await http.get(uri, headers: {
        'X-RapidAPI-Key': _rapidApiKey,
        'X-RapidAPI-Host': _rapidApiHost,
      }).timeout(const Duration(seconds: 15));

      print("API URL: $uri");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['data'] as List?;
        if (items == null || items.isEmpty) return [];

        final events = items
            .asMap()
            .entries
            .map((e) => _parse(e.value, e.key))
            .whereType<EventModel>()
            .toList();

        if (lat != null && lng != null && events.isNotEmpty) {
          events.sort((a, b) {
            final dA =
                Geolocator.distanceBetween(lat, lng, a.latitude, a.longitude);
            final dB =
                Geolocator.distanceBetween(lat, lng, b.latitude, b.longitude);
            return dA.compareTo(dB);
          });
        }
        return events;
      }
      return [];
    } catch (e) {
      print('EventRepository error: $e');
      return [];
    }
  }

  EventModel? _parse(Map<String, dynamic> item, int index) {
    try {
      final name = item['name']?.toString() ?? 'Event';
      final description = item['description']?.toString() ??
          'Tap to view full event details and book tickets.';
      final link = item['link']?.toString() ?? '';

      DateTime date = DateTime.now().add(Duration(days: 7 + index * 2));
      final startTime = item['start_time']?.toString() ?? '';
      if (startTime.isNotEmpty) {
        date = DateTime.tryParse(startTime) ?? date;
      }

      String image =
          'https://picsum.photos/seed/${name.hashCode.abs()}/800/400';
      final thumb = item['thumbnail']?.toString() ?? '';
      if (thumb.startsWith('http')) image = thumb;

      String venue = 'India';
      String city = 'India';
      double eLat = 20.5937;
      double eLng = 78.9629;

      final v = item['venue'];
      if (v != null) {
        final vName = v['name']?.toString() ?? '';
        final vCity = v['city']?.toString() ?? '';
        final vState = v['state']?.toString() ?? '';
        city = vCity.isNotEmpty ? vCity : vState;
        final parts = [vName, vCity, vState].where((s) => s.isNotEmpty);
        venue = parts.join(', ');
        if (venue.isEmpty) venue = city;

        final pLat = double.tryParse(v['latitude']?.toString() ?? '');
        final pLng = double.tryParse(v['longitude']?.toString() ?? '');
        if (pLat != null && pLng != null && pLat != 0 && pLng != 0) {
          eLat = pLat;
          eLng = pLng;
        } else {
          final known = _cityCoords[vCity] ?? _cityCoords[vState];
          if (known != null) {
            eLat = known[0] + index * 0.004;
            eLng = known[1] + index * 0.004;
          }
        }
      }

      String bookingUrl = link;

      final tickets = item['ticket_links'];

      if (tickets is List && tickets.isNotEmpty) {

        final firstTicket = tickets.first;

        if (firstTicket is Map && firstTicket['link'] != null) {
          bookingUrl = firstTicket['link'].toString();
        }
      }

      if (bookingUrl.isEmpty) {
        bookingUrl =
            item['event_link']?.toString() ??
                item['url']?.toString() ??
                item['link']?.toString() ??
                '';
      }

      print("BOOKING URL: $bookingUrl");

      final isFree = name.toLowerCase().contains('free') ||
          description.toLowerCase().contains('free entry') ||
          description.toLowerCase().contains('free admission');

      return EventModel(
        id: 'rapid_${name.hashCode.abs()}_$index',
        title: name,
        description: description.length > 300
            ? '${description.substring(0, 300)}...'
            : description,
        category: _category(name + description),
        imageUrl: image,
        dateTime: date,
        venue: venue.isNotEmpty ? venue : 'India',
        latitude: eLat,
        longitude: eLng,
        city: city.isNotEmpty ? city : 'India',
        isFree: isFree,
        price: null,
        externalUrl: bookingUrl.isNotEmpty ? bookingUrl : link,
        attendeeCount: 0,
      );
    } catch (e) {
      return null;
    }
  }

  String _category(String text) {
    final t = text.toLowerCase();
    if (t.contains('concert') ||
        t.contains('music') ||
        t.contains('dj') ||
        t.contains('band') ||
        t.contains('garba') ||
        t.contains('bollywood')) return 'music';
    if (t.contains('cricket') ||
        t.contains('ipl') ||
        t.contains('football') ||
        t.contains('match') ||
        t.contains('sport') ||
        t.contains('marathon')) return 'sports';
    if (t.contains('comedy') ||
        t.contains('theatre') ||
        t.contains('dance') ||
        t.contains('art') ||
        t.contains('exhibition') ||
        t.contains('film')) return 'art';
    if (t.contains('tech') ||
        t.contains('workshop') ||
        t.contains('hackathon') ||
        t.contains('startup') ||
        t.contains('meetup') ||
        t.contains('conference') ||
        t.contains('flutter') ||
        t.contains('ai ')) return 'tech';
    if (t.contains('food') ||
        t.contains('mela') ||
        t.contains('fair') ||
        t.contains('carnival') ||
        t.contains('culinary')) return 'food';
    if (t.contains('yoga') ||
        t.contains('wellness') ||
        t.contains('community') ||
        t.contains('charity')) return 'community';
    return 'music';
  }
}
