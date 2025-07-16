class Memory {
  final String id;
  final String image;
  final String description;
  final DateTime date;
  final String time;
  final bool isFavorite;

  Memory({
    required this.id,
    required this.image,
    required this.description,
    required this.date,
    required this.time,
    required this.isFavorite,
  });

  factory Memory.fromJson(Map<String, dynamic> json) {
    print('Parsing JSON: $json'); // تتبع القيم اللي بتيجي
    return Memory(
      id: json['_id'] as String? ?? '',
      image: json['image'] as String? ?? '',
      description: json['description'] as String? ?? '',
      date: (json['date'] != null)
          ? (DateTime.tryParse(json['date'] as String)?.toLocal() ?? DateTime.now())
          : DateTime.now(),
      time: json['time'] as String? ?? '00:00',
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'image': image.isEmpty ? null : image,
      'description': description,
      'date': date.toIso8601String(),
      'time': time,
      'isFavorite': isFavorite,
    };
  }

  Memory copyWith({
    String? id,
    String? image,
    String? description,
    DateTime? date,
    String? time,
    bool? isFavorite,
  }) {
    return Memory(
      id: id ?? this.id,
      image: image ?? this.image,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}