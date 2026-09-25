import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:m18_shared/m18_shared.dart';

abstract class TenantEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTenants extends TenantEvent {}

class AddTenant extends TenantEvent {
  final TenantRequest request;

  AddTenant(this.request);

  @override
  List<Object?> get props => [request];
}

class UpdateTenantEvent extends TenantEvent {
  final int id;
  final TenantRequest request;

  UpdateTenantEvent(this.id, this.request);

  @override
  List<Object?> get props => [id, request];
}

class DeleteTenant extends TenantEvent {
  final int id;
  final Completer<void> onComplete;

  DeleteTenant(this.id, {required this.onComplete});
}
