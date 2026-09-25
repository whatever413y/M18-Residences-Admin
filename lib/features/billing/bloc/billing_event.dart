import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:m18_shared/m18_shared.dart';

abstract class BillingEvent extends Equatable {
  const BillingEvent();

  @override
  List<Object?> get props => [];
}

class LoadBills extends BillingEvent {}

class AddBill extends BillingEvent {
  final BillRequest request;

  const AddBill(this.request);

  @override
  List<Object?> get props => [request];
}

class UpdateBill extends BillingEvent {
  final int id;
  final BillRequest request;

  /// Receipt image picked in the form; when set, the update is sent together with the file upload.
  final PlatformFile? receiptFile;

  const UpdateBill(this.id, this.request, {this.receiptFile});

  @override
  List<Object?> get props => [id, request, receiptFile];
}

class DeleteBill extends BillingEvent {
  final int id;
  final Completer<void> onComplete;

  DeleteBill(this.id, {required this.onComplete});
}
