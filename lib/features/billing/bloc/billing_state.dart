import 'package:equatable/equatable.dart';
import 'package:m18_residences_admin/models/billing.dart';
import 'package:m18_residences_admin/models/reading.dart';
import 'package:m18_residences_admin/models/room.dart';
import 'package:m18_residences_admin/models/tenant.dart';

abstract class BillingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BillingInitial extends BillingState {}

class BillingLoading extends BillingState {}

class AddSuccess extends BillingState {}

class UpdateSuccess extends BillingState {}

class DeleteSuccess extends BillingState {}

class BillingLoaded extends BillingState {
  final List<Bill> bills;
  final List<Room> rooms;
  final List<Tenant> tenants;
  final List<Reading> readings;

  BillingLoaded(this.bills, this.rooms, this.tenants, this.readings);

  @override
  List<Object?> get props => [bills, rooms, tenants, readings];
}

class BillingError extends BillingState {
  final String message;
  BillingError(this.message);

  @override
  List<Object?> get props => [message];
}
