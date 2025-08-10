class Tenant {
  final int? id;
  final int roomId;
  final String name;
  final DateTime joinDate;
  final bool isActive;

  Tenant({this.id, required this.roomId, required this.name, required this.joinDate, required this.isActive});

  factory Tenant.fromJson(Map<String, dynamic> json) =>
      Tenant(id: json['id'], roomId: json['roomId'], name: json['name'], joinDate: DateTime.parse(json['joinDate']), isActive: json['isActive']);

  Map<String, dynamic> toJson() => {'name': name, 'roomId': roomId, 'joinDate': joinDate.toIso8601String(), 'isActive': isActive};
}
