import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:m18_residences_admin/models/room.dart';

abstract class RoomEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadRooms extends RoomEvent {}

class AddRoom extends RoomEvent {
  final Room room;

  AddRoom(this.room);

  @override
  List<Object?> get props => [room];
}

class UpdateRoom extends RoomEvent {
  final Room room;

  UpdateRoom(this.room);

  @override
  List<Object?> get props => [room];
}

class DeleteRoom extends RoomEvent {
  final int id;
  final Completer<void> onComplete;

  DeleteRoom(this.id, {required this.onComplete});
}
