import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/features/room/bloc/room_event.dart';
import 'package:rental_management_system_flutter/features/room/bloc/room_state.dart';
import 'package:rental_management_system_flutter/services/room_service.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final RoomService roomService;

  RoomBloc(this.roomService) : super(RoomInitial()) {
    on<LoadRooms>(_onLoadRooms);
    on<AddRoom>(_onAddRoom);
    on<UpdateRoom>(_onUpdateRoom);
    on<DeleteRoom>(_onDeleteRoom);
  }

  Future<void> _onLoadRooms(LoadRooms event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    try {
      final rooms = await roomService.fetchRooms();
      emit(RoomLoaded(rooms));
    } catch (e) {
      emit(RoomError('Failed to load rooms: $e'));
    }
  }

  Future<void> _onAddRoom(AddRoom event, Emitter<RoomState> emit) async {
    try {
      await roomService.createRoom(event.room.name, event.room.rent);
      add(LoadRooms());
      emit(AddSuccess());
    } catch (e) {
      emit(RoomError('Failed to create room: $e'));
    }
  }

  Future<void> _onUpdateRoom(UpdateRoom event, Emitter<RoomState> emit) async {
    try {
      await roomService.updateRoom(event.room.id!, event.room.name, event.room.rent);
      add(LoadRooms());
      emit(UpdateSuccess());
    } catch (e) {
      emit(RoomError('Failed to update room: $e'));
    }
  }

  Future<void> _onDeleteRoom(DeleteRoom event, Emitter<RoomState> emit) async {
    try {
      await roomService.deleteRoom(event.id);
      event.onComplete.complete();
      add(LoadRooms());
      emit(DeleteSuccess());
    } catch (e) {
      event.onComplete.completeError(e);
      emit(RoomError('Failed to delete room: $e'));
    }
  }
}
