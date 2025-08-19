class Tenant {
  final int? id;
  final int roomId;
  final String name;
  final DateTime joinDate;
  final bool isActive;

  Tenant({this.id, required this.roomId, required this.name, required this.joinDate, required this.isActive});

  factory Tenant.fromJson(Map<String, dynamic> json) =>
  
  Tenant(id: json['id'], roomId: json['room_id'], name: json['name'], joinDate: DateTime.parse(json['join_date']), isActive: json['is_active']);
  
  Map<String, dynamic> toJson() => {'name': name, 'room_id': roomId, 'join_date': joinDate.toIso8601String(), 'is_active': isActive};
}
