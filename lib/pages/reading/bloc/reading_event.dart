import 'package:rental_management_system_flutter/models/reading.dart';

abstract class ReadingEvent {}

class LoadReadings extends ReadingEvent {}

class AddReading extends ReadingEvent {
  final Reading reading;

  AddReading(this.reading);
}

class UpdateReading extends ReadingEvent {
  final Reading reading;

  UpdateReading(this.reading);
}

class DeleteReading extends ReadingEvent {
  final int id;

  DeleteReading(this.id);
}
