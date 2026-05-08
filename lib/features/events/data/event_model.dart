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
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'music',
      imageUrl: json['imageUrl'] as String? ?? '',
      videoUrl: json['videoUrl'] as String?,
      dateTime: DateTime.parse(json['dateTime'] as String),
      venue: json['venue'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      city: json['city'] as String? ?? '',
      isFree: json['isFree'] as bool? ?? false,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      externalUrl: json['externalUrl'] as String?,
      attendeeCount: json['attendeeCount'] as int? ?? 0,
      isSaved: json['isSaved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'dateTime': dateTime.toIso8601String(),
      'venue': venue,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'isFree': isFree,
      'price': price,
      'externalUrl': externalUrl,
      'attendeeCount': attendeeCount,
      'isSaved': isSaved,
    };
  }
}
