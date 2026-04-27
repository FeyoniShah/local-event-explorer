import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../events/presentation/providers/events_provider.dart';
import '../../../events/data/dummy_events.dart';
import '../../../events/data/event_model.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  EventModel? _selectedEvent;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });
        _mapController.move(
            LatLng(position.latitude, position.longitude), 12);
      } else {
        setState(() => _isLoadingLocation = false);
      }
    } catch (e) {
      setState(() => _isLoadingLocation = false);
    }
  }

  String _getDistance(EventModel event) {
    if (_currentPosition == null) return '';
    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      event.latitude,
      event.longitude,
    );
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}m away';
    }
    return '${(distance / 1000).toStringAsFixed(1)}km away';
  }

  Future<void> _openDirections(EventModel event) async {
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${event.latitude},${event.longitude}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openEventUrl(EventModel event) async {
    if (event.externalUrl == null) return;
    final url = Uri.parse(event.externalUrl!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Map'),
        actions: [
          if (_isLoadingLocation)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () {
                if (_currentPosition != null) {
                  _mapController.move(
                      LatLng(_currentPosition!.latitude,
                          _currentPosition!.longitude),
                      14);
                }
              },
            ),
        ],
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildMap(dummyEvents),
        data: (events) => _buildMap(events.isEmpty ? dummyEvents : events),
      ),
    );
  }

  Widget _buildMap(List<EventModel> events) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(18.5204, 73.8567),
            initialZoom: 11,
            onTap: (_, __) => setState(() => _selectedEvent = null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.local_event_explorer',
            ),

            // Current location
            if (_currentPosition != null)
              MarkerLayer(markers: [
                Marker(
                  point: LatLng(_currentPosition!.latitude,
                      _currentPosition!.longitude),
                  width: 44,
                  height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 6)
                      ],
                    ),
                    child: const Icon(Icons.person,
                        color: Colors.white, size: 22),
                  ),
                ),
              ]),

            // Event pins
            MarkerLayer(
              markers: events.map((event) {
                final isSelected = _selectedEvent?.id == event.id;
                return Marker(
                  point: LatLng(event.latitude, event.longitude),
                  width: 52,
                  height: 52,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedEvent = event);
                      _mapController.move(
                          LatLng(event.latitude, event.longitude), 14);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : _getCategoryColor(event.category),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 6)
                        ],
                      ),
                      child: Icon(
                        _getCategoryIcon(event.category),
                        color: Colors.white,
                        size: isSelected ? 28 : 22,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // Event detail card
        if (_selectedEvent != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(_selectedEvent!.title,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => _selectedEvent = null),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(_selectedEvent!.venue,
                              style: const TextStyle(color: Colors.grey),
                              overflow: TextOverflow.ellipsis)),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${_selectedEvent!.dateTime.day}/${_selectedEvent!.dateTime.month}/${_selectedEvent!.dateTime.year}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.directions_walk,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(_getDistance(_selectedEvent!),
                          style: const TextStyle(color: Colors.grey)),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _openDirections(_selectedEvent!),
                          icon: const Icon(Icons.directions, size: 18),
                          label: const Text('Directions'),
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10)),
                        ),
                      ),
                      if (_selectedEvent!.externalUrl != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _openEventUrl(_selectedEvent!),
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: const Text('View Event'),
                            style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10)),
                          ),
                        ),
                      ],
                    ]),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'music': return Colors.purple;
      case 'sports': return Colors.green;
      case 'art': return Colors.orange;
      case 'tech': return Colors.blue;
      case 'food': return Colors.red;
      default: return Colors.teal;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'music': return Icons.music_note;
      case 'sports': return Icons.sports_cricket;
      case 'art': return Icons.palette;
      case 'tech': return Icons.computer;
      case 'food': return Icons.restaurant;
      default: return Icons.event;
    }
  }
}