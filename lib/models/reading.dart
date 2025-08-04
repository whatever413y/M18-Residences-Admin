class Reading {
  final int id;
  final int tenantId;
  final int roomId;
  final int prevReading;
  final int currReading;
  final int consumption;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reading({
    required this.id,
    required this.tenantId,
    required this.roomId,
    required this.prevReading,
    required this.currReading,
    required this.consumption,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      id: json['id'],
      tenantId: json['tenantId'],
      roomId: json['roomId'],
      prevReading: json['prevReading'],
      currReading: json['currReading'],
      consumption: json['consumption'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenantId': tenantId,
      'roomId': roomId,
      'prevReading': prevReading,
      'currReading': currReading,
    };
  }
}
