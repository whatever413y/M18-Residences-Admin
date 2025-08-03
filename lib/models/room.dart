class Room {
  final int id;
  final String name;
  final double rent;

  Room({required this.id, required this.name, required this.rent});

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json['id'],
    name: json['name'],
    rent: (json['rent'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {'name': name, 'rent': rent};
}
