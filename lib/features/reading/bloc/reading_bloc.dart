import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m18_shared/m18_shared.dart';

import 'reading_event.dart';
import 'reading_state.dart';

class ReadingBloc extends Bloc<ReadingEvent, ReadingState> {
  final ReadingApi readingApi;
  final RoomApi roomApi;
  final TenantApi tenantApi;

  ReadingBloc({required this.readingApi, required this.roomApi, required this.tenantApi}) : super(ReadingInitial()) {
    on<LoadReadings>(_onLoadReadings);
    on<AddReading>(_onAddReading);
    on<UpdateReading>(_onUpdateReading);
    on<DeleteReading>(_onDeleteReading);
  }

  Future<void> _onLoadReadings(LoadReadings event, Emitter<ReadingState> emit) async {
    emit(ReadingLoading());
    try {
      final readings = await readingApi.list();
      final rooms = await roomApi.list();
      final tenants = await tenantApi.list();
      emit(ReadingLoaded(readings, rooms, tenants));
    } catch (e) {
      emit(ReadingError('Failed to load readings: $e'));
    }
  }

  Future<void> _onAddReading(AddReading event, Emitter<ReadingState> emit) async {
    try {
      await readingApi.create(event.request);
      add(LoadReadings());
      emit(AddSuccess());
    } catch (e) {
      emit(ReadingError('Failed to add reading: $e'));
    }
  }

  Future<void> _onUpdateReading(UpdateReading event, Emitter<ReadingState> emit) async {
    try {
      await readingApi.update(event.id, event.request);
      add(LoadReadings());
      emit(UpdateSuccess());
    } catch (e) {
      emit(ReadingError('Failed to update reading: $e'));
    }
  }

  Future<void> _onDeleteReading(DeleteReading event, Emitter<ReadingState> emit) async {
    try {
      await readingApi.delete(event.id);
      event.onComplete.complete();
      add(LoadReadings());
      emit(DeleteSuccess());
    } catch (e) {
      event.onComplete.completeError(e);
      emit(ReadingError('Failed to delete reading: $e'));
    }
  }
}
