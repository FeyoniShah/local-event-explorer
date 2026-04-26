class EventModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final String? videoUrl;
  final DateTime dateTime;
  final String venue;
  final double latitude;
  final double longitude;
  final String city;
  final bool isFree;
  final double? price;
  final String? externalUrl;
  final int attendeeCount;
  final bool isSaved;
 
  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    this.videoUrl,
    required this.dateTime,
    required this.venue,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.isFree,
    this.price,
    this.externalUrl,
    required this.attendeeCount,
    this.isSaved = false,
  });
}
