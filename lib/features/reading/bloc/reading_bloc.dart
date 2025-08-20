import 'package:flutter_bloc/flutter_bloc.dart';
import 'reading_event.dart';
import 'reading_state.dart';
import 'package:m18_residences_admin/services/reading_service.dart';
import 'package:m18_residences_admin/services/room_service.dart';
import 'package:m18_residences_admin/services/tenant_service.dart';

class ReadingBloc extends Bloc<ReadingEvent, ReadingState> {
  final ReadingService readingService;
  final RoomService roomService;
  final TenantService tenantService;

  ReadingBloc({required this.readingService, required this.roomService, required this.tenantService}) : super(ReadingInitial()) {
    on<LoadReadings>(_onLoadReadings);
    on<AddReading>(_onAddReading);
    on<UpdateReading>(_onUpdateReading);
    on<DeleteReading>(_onDeleteReading);
  }

  Future<void> _onLoadReadings(LoadReadings event, Emitter<ReadingState> emit) async {
    emit(ReadingLoading());
    try {
      final readings = await readingService.fetchReadings();
      final rooms = await roomService.fetchRooms();
      final tenants = await tenantService.fetchTenants();
      emit(ReadingLoaded(readings, rooms, tenants));
    } catch (e) {
      emit(ReadingError('Failed to load readings: $e'));
    }
  }

  Future<void> _onAddReading(AddReading event, Emitter<ReadingState> emit) async {
    try {
      await readingService.createReading(
        roomId: event.reading.roomId,
        tenantId: event.reading.tenantId,
        prevReading: event.reading.prevReading,
        currReading: event.reading.currReading,
      );
      add(LoadReadings());
      emit(AddSuccess());
    } catch (e) {
      emit(ReadingError('Failed to add reading: $e'));
    }
  }

  Future<void> _onUpdateReading(UpdateReading event, Emitter<ReadingState> emit) async {
    try {
      await readingService.updateReading(
        id: event.reading.id!,
        roomId: event.reading.roomId,
        tenantId: event.reading.tenantId,
        prevReading: event.reading.prevReading,
        currReading: event.reading.currReading,
      );
      add(LoadReadings());
      emit(UpdateSuccess());
    } catch (e) {
      emit(ReadingError('Failed to update reading: $e'));
    }
  }

  Future<void> _onDeleteReading(DeleteReading event, Emitter<ReadingState> emit) async {
    try {
      await readingService.deleteReading(event.id);
      event.onComplete.complete();
      add(LoadReadings());
      emit(DeleteSuccess());
    } catch (e) {
      event.onComplete.completeError(e);
      emit(ReadingError('Failed to delete reading: $e'));
    }
  }
}
