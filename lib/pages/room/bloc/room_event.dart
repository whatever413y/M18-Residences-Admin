import 'package:equatable/equatable.dart';
import 'package:rental_management_system_flutter/models/room.dart';

abstract class RoomEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadRooms extends RoomEvent {}

class AddRoom extends RoomEvent {
  final String name;
  final double rent;

  AddRoom(this.name, this.rent);

  @override
  List<Object?> get props => [name, rent];
}

class UpdateRoom extends RoomEvent {
  final Room room;

  UpdateRoom(this.room);

  @override
  List<Object?> get props => [room];
}

class DeleteRoom extends RoomEvent {
  final int roomId;

  DeleteRoom(this.roomId);

  @override
  List<Object?> get props => [roomId];
}
