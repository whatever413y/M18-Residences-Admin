import 'package:equatable/equatable.dart';
import 'package:m18_shared/m18_shared.dart';

abstract class RoomState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RoomInitial extends RoomState {}

class RoomLoading extends RoomState {}

class AddSuccess extends RoomState {}

class UpdateSuccess extends RoomState {}

class DeleteSuccess extends RoomState {}

class RoomLoaded extends RoomState {
  final List<Room> rooms;

  RoomLoaded(this.rooms);

  @override
  List<Object?> get props => [rooms];
}

class RoomError extends RoomState {
  final String message;

  RoomError(this.message);

  @override
  List<Object?> get props => [message];
}
