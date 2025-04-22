class Memory {
  final String id;
  final String image;
  final String description;
  final DateTime date;
  final String time;
  bool isFavorite;

  Memory({
    required this.id,
    required this.image,
    required this.description,
    required this.date,
    required this.time,
    required this.isFavorite,
  });

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['_id'],
      image: json['image'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'description': description,
      'date': date.toIso8601String().split('T')[0],
      'time': time,
      'isFavorite': isFavorite,
    };
  }
}