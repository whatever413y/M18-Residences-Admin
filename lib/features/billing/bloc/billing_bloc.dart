import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m18_shared/m18_shared.dart';

import 'billing_event.dart';
import 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final ReadingApi readingApi;
  final RoomApi roomApi;
  final TenantApi tenantApi;
  final BillApi billApi;

  BillingBloc({required this.readingApi, required this.roomApi, required this.tenantApi, required this.billApi}) : super(BillingInitial()) {
    on<LoadBills>(_onLoadBills);
    on<AddBill>(_onAddBill);
    on<UpdateBill>(_onUpdateBill);
    on<DeleteBill>(_onDeleteBill);
  }

  Future<void> _onLoadBills(LoadBills event, Emitter<BillingState> emit) async {
    emit(BillingLoading());
    try {
      final bills = await billApi.list();
      final rooms = await roomApi.list();
      final tenants = await tenantApi.list();
      final readings = await readingApi.list();
      emit(BillingLoaded(bills, rooms, tenants, readings));
    } catch (e) {
      emit(BillingError('Failed to load billing data: $e'));
    }
  }

  Future<void> _onAddBill(AddBill event, Emitter<BillingState> emit) async {
    try {
      await billApi.create(event.request);
      add(LoadBills());
      emit(AddSuccess());
    } catch (e) {
      emit(BillingError('Failed to create bill: $e'));
    }
  }

  Future<void> _onUpdateBill(UpdateBill event, Emitter<BillingState> emit) async {
    try {
      final receiptFile = event.receiptFile;
      if (receiptFile == null) {
        await billApi.update(event.id, event.request);
      } else {
        await billApi.uploadReceipt(event.id, event.request, bytes: await receiptFile.readAsBytes(), filename: receiptFile.name);
      }
      add(LoadBills());
      emit(UpdateSuccess());
    } catch (e) {
      emit(BillingError('Failed to update bill: $e'));
    }
  }

  Future<void> _onDeleteBill(DeleteBill event, Emitter<BillingState> emit) async {
    try {
      await billApi.delete(event.id);
      event.onComplete.complete();
      add(LoadBills());
      emit(DeleteSuccess());
    } catch (e) {
      event.onComplete.completeError(e);
      emit(BillingError('Failed to delete bill: $e'));
    }
  }
}
