import 'package:flutter/material.dart';
import '../../../events/data/dummy_events.dart';
 
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Event Map")),
      body: Stack(
        children: [
          Container(
            color: Colors.grey[850],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Map View", style: TextStyle(fontSize: 20,
                      fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("Google Maps integration coming soon",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16, left: 16, right: 16,
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dummyEvents.length,
                itemBuilder: (context, index) {
                  final event = dummyEvents[index];
                  return Card(
                    margin: const EdgeInsets.only(right: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(event.title, style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(event.venue, style: const TextStyle(
                              color: Colors.grey, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(event.isFree ? "FREE"
                              : "₹${event.price?.toStringAsFixed(0)}",
                            style: TextStyle(fontWeight: FontWeight.bold,
                              color: event.isFree ? Colors.green : null)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
