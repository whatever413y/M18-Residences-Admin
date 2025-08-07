import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:rental_management_system_flutter/models/billing.dart';

abstract class BillingEvent extends Equatable {
  const BillingEvent();

  @override
  List<Object?> get props => [];
}

class LoadBills extends BillingEvent {}

class AddBill extends BillingEvent {
  final Bill bill;

  const AddBill(this.bill);

  @override
  List<Object?> get props => [bill];
}

class UpdateBill extends BillingEvent {
  final Bill bill;

  const UpdateBill(this.bill);

  @override
  List<Object?> get props => [bill];
}

class DeleteBill extends BillingEvent {
  final int id;
  final Completer<void> onComplete;

  DeleteBill(this.id, {required this.onComplete});
}
