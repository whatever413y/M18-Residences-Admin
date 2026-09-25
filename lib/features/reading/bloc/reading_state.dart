import 'package:equatable/equatable.dart';
import 'package:m18_shared/m18_shared.dart';

abstract class ReadingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReadingInitial extends ReadingState {}

class ReadingLoading extends ReadingState {}

class AddSuccess extends ReadingState {}

class UpdateSuccess extends ReadingState {}

class DeleteSuccess extends ReadingState {}

class ReadingLoaded extends ReadingState {
  final List<Reading> readings;
  final List<Room> rooms;
  final List<Tenant> tenants;

  ReadingLoaded(this.readings, this.rooms, this.tenants);

  @override
  List<Object?> get props => [readings, rooms, tenants];
}

class ReadingError extends ReadingState {
  final String message;

  ReadingError(this.message);

  @override
  List<Object?> get props => [message];
}
