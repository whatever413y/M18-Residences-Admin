import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:m18_residences_admin/models/tenant.dart';

abstract class TenantEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTenants extends TenantEvent {}

class AddTenant extends TenantEvent {
  final Tenant tenant;

  AddTenant(this.tenant);

  @override
  List<Object?> get props => [tenant];
}

class UpdateTenantEvent extends TenantEvent {
  final Tenant tenant;

  UpdateTenantEvent(this.tenant);

  @override
  List<Object?> get props => [tenant];
}

class DeleteTenant extends TenantEvent {
  final int id;
  final Completer<void> onComplete;

  DeleteTenant(this.id, {required this.onComplete});
}
