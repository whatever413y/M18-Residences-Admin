import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:m18_shared/m18_shared.dart';

abstract class RoomEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadRooms extends RoomEvent {}

class AddRoom extends RoomEvent {
  final RoomRequest request;

  AddRoom(this.request);

  @override
  List<Object?> get props => [request];
}

class UpdateRoom extends RoomEvent {
  final int id;
  final RoomRequest request;

  UpdateRoom(this.id, this.request);

  @override
  List<Object?> get props => [id, request];
}

class DeleteRoom extends RoomEvent {
  final int id;
  final Completer<void> onComplete;

  DeleteRoom(this.id, {required this.onComplete});
}
