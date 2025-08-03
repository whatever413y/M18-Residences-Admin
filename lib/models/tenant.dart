class Tenant {
  final int id;
  final String name;
  final int roomId;
  final String roomName;
  final DateTime joinDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tenant({
    required this.id,
    required this.name,
    required this.roomId,
    required this.roomName,
    required this.joinDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
    id: json['id'],
    name: json['name'],
    roomId: json['roomId'],
    roomName: json['roomName'] ?? '',
    joinDate: DateTime.parse(json['joinDate']),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'roomId': roomId,
    'joinDate': joinDate.toIso8601String(),
  };
}
