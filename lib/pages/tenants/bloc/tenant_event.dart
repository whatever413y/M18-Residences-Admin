import 'package:equatable/equatable.dart';

abstract class TenantEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTenants extends TenantEvent {}

class AddTenant extends TenantEvent {
  final String name;
  final int roomId;
  final DateTime joinDate;

  AddTenant(this.name, this.roomId, this.joinDate);

  @override
  List<Object?> get props => [name, roomId, joinDate];
}

class UpdateTenantEvent extends TenantEvent {
  final int id;
  final String name;
  final int roomId;
  final DateTime joinDate;

  UpdateTenantEvent(this.id, this.name, this.roomId, this.joinDate);

  @override
  List<Object?> get props => [id, name, roomId, joinDate];
}

class DeleteTenant extends TenantEvent {
  final int id;

  DeleteTenant(this.id);

  @override
  List<Object?> get props => [id];
}
