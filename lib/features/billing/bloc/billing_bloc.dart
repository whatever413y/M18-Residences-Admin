import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m18_residences_admin/services/reading_service.dart';
import 'package:m18_residences_admin/services/room_service.dart';
import 'package:m18_residences_admin/services/tenant_service.dart';
import 'billing_event.dart';
import 'billing_state.dart';
import 'package:m18_residences_admin/services/billing_service.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final ReadingService readingService;
  final RoomService roomService;
  final TenantService tenantService;
  final BillingService billingService;

  BillingBloc({required this.readingService, required this.roomService, required this.tenantService, required this.billingService})
    : super(BillingInitial()) {
    on<LoadBills>(_onLoadBills);
    on<AddBill>(_onAddBill);
    on<UpdateBill>(_onUpdateBill);
    on<DeleteBill>(_onDeleteBill);
  }

  Future<void> _onLoadBills(LoadBills event, Emitter<BillingState> emit) async {
    emit(BillingLoading());
    try {
      final bills = await billingService.fetchBills();
      final rooms = await roomService.fetchRooms();
      final tenants = await tenantService.fetchTenants();
      final readings = await readingService.fetchReadings();
      emit(BillingLoaded(bills, rooms, tenants, readings));
    } catch (e) {
      emit(BillingError('Failed to load billing data: $e'));
    }
  }

  Future<void> _onAddBill(AddBill event, Emitter<BillingState> emit) async {
    try {
      await billingService.createBill(
        tenantId: event.bill.tenantId,
        readingId: event.bill.readingId,
        roomCharges: event.bill.roomCharges,
        electricCharges: event.bill.electricCharges,
        additionalCharges: event.bill.additionalCharges,
      );
      add(LoadBills());
      emit(AddSuccess());
    } catch (e) {
      emit(BillingError('Failed to create bill: $e'));
    }
  }

  Future<void> _onUpdateBill(UpdateBill event, Emitter<BillingState> emit) async {
    try {
      await billingService.updateBill(
        id: event.bill.id!,
        tenantId: event.bill.tenantId,
        readingId: event.bill.readingId,
        roomCharges: event.bill.roomCharges,
        electricCharges: event.bill.electricCharges,
        additionalCharges: event.bill.additionalCharges,
        receiptFile: event.bill.receiptFile,
        receiptUrl: event.bill.receiptUrl,
      );
      add(LoadBills());
      emit(UpdateSuccess());
    } catch (e) {
      emit(BillingError('Failed to update bill: $e'));
    }
  }

  Future<void> _onDeleteBill(DeleteBill event, Emitter<BillingState> emit) async {
    try {
      await billingService.deleteBill(event.id);
      event.onComplete.complete();
      add(LoadBills());
      emit(DeleteSuccess());
    } catch (e) {
      event.onComplete.completeError(e);
      emit(BillingError('Failed to delete bill: $e'));
    }
  }
}
