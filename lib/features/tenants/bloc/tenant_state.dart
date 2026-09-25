import 'package:equatable/equatable.dart';
import 'package:m18_shared/m18_shared.dart';

abstract class TenantState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TenantInitial extends TenantState {}

class TenantLoading extends TenantState {}

class AddSuccess extends TenantState {}

class UpdateSuccess extends TenantState {}

class DeleteSuccess extends TenantState {}

class TenantLoaded extends TenantState {
  final List<Tenant> tenants;
  final List<Room> rooms;

  TenantLoaded(this.tenants, this.rooms);

  @override
  List<Object?> get props => [tenants, rooms];
}

class TenantError extends TenantState {
  final String message;

  TenantError(this.message);

  @override
  List<Object?> get props => [message];
}
