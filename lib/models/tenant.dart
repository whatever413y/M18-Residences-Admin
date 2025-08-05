class Tenant {
  final int? id;
  final int roomId;
  final String name;
  final DateTime joinDate;

  Tenant({
    this.id,
    required this.roomId,
    required this.name,
    required this.joinDate,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
    id: json['id'],
    roomId: json['roomId'],
    name: json['name'],
    joinDate: DateTime.parse(json['joinDate']),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'roomId': roomId,
    'joinDate': joinDate.toIso8601String(),
  };
}
