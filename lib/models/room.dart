class Room {
  final int? id;
  final String name;
  final int rent;

  Room({this.id, required this.name, required this.rent});

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json['id'],
    name: json['name'],
    rent: (json['rent'] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {'name': name, 'rent': rent};
}
