class Tenant {
  final int id;
  final int roomId;
  final String name;
  final DateTime joinDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tenant({
    required this.id,
    required this.roomId,
    required this.name,
    required this.joinDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
    id: json['id'],
    roomId: json['roomId'],
    name: json['name'],
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
