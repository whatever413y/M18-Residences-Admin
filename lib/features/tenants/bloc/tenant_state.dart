import 'package:equatable/equatable.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/models/room.dart';

abstract class TenantState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TenantInitial extends TenantState {}

class TenantLoading extends TenantState {}

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
