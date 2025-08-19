class Reading {
  final int? id;
  final int tenantId;
  final int roomId;
  final int prevReading;
  final int currReading;
  final int? consumption;
  final DateTime? createdAt;

  Reading({
    this.id,
    required this.tenantId,
    required this.roomId,
    required this.prevReading,
    required this.currReading,
    this.consumption,
    this.createdAt,
  });

  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      id: json['id'],
      tenantId: json['tenant_id'],
      roomId: json['room_id'],
      prevReading: json['prev_reading'],
      currReading: json['curr_reading'],
      consumption: json['consumption'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'tenant_id': tenantId, 'room_id': roomId, 'prev_reading': prevReading, 'curr_reading': currReading};
  }
}
