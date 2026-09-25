import 'dart:async';

import 'package:m18_shared/m18_shared.dart';

abstract class ReadingEvent {}

class LoadReadings extends ReadingEvent {}

class AddReading extends ReadingEvent {
  final ReadingRequest request;

  AddReading(this.request);
}

class UpdateReading extends ReadingEvent {
  final int id;
  final ReadingRequest request;

  UpdateReading(this.id, this.request);
}

class DeleteReading extends ReadingEvent {
  final int id;
  final Completer<void> onComplete;

  DeleteReading(this.id, {required this.onComplete});
}
