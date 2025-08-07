import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/services/reading_service.dart';
import 'package:rental_management_system_flutter/services/room_service.dart';
import 'package:rental_management_system_flutter/services/tenant_service.dart';
import 'billing_event.dart';
import 'billing_state.dart';
import 'package:rental_management_system_flutter/services/billing_service.dart';
import 'package:rental_management_system_flutter/models/billing.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final ReadingService readingService;
  final RoomService roomService;
  final TenantService tenantService;
  final BillingService billingService;

  BillingBloc({
    required this.readingService,
    required this.roomService,
    required this.tenantService,
    required this.billingService,
  }) : super(BillingInitial()) {
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
      emit(BillingError('Failed to load billing data'));
    }
  }

  Future<void> _onAddBill(AddBill event, Emitter<BillingState> emit) async {
    if (state is! BillingLoaded) return;
    final currentState = state as BillingLoaded;
    try {
      final newBill = await billingService.createBill(
        tenantId: event.bill.tenantId,
        readingId: event.bill.readingId,
        roomCharges: event.bill.roomCharges,
        electricCharges: event.bill.electricCharges,
        additionalCharges: event.bill.additionalCharges,
        additionalDescription: event.bill.additionalDescription,
      );
      final updatedList = List<Bill>.from(currentState.bills)..add(newBill);
      emit(
        BillingLoaded(
          updatedList,
          currentState.rooms,
          currentState.tenants,
          currentState.readings,
        ),
      );
    } catch (_) {
      emit(BillingError('Failed to create bill'));
    }
  }

  Future<void> _onUpdateBill(
    UpdateBill event,
    Emitter<BillingState> emit,
  ) async {
    if (state is! BillingLoaded) return;
    final currentState = state as BillingLoaded;
    try {
      final updatedBill = await billingService.updateBill(
        id: event.bill.id!,
        tenantId: event.bill.tenantId,
        readingId: event.bill.readingId,
        roomCharges: event.bill.roomCharges,
        electricCharges: event.bill.electricCharges,
        additionalCharges: event.bill.additionalCharges,
        additionalDescription: event.bill.additionalDescription,
      );

      final updatedList =
          currentState.bills.map((b) {
            return b.id == updatedBill.id ? updatedBill : b;
          }).toList();

      emit(
        BillingLoaded(
          updatedList,
          currentState.rooms,
          currentState.tenants,
          currentState.readings,
        ),
      );
    } catch (_) {
      emit(BillingError('Failed to update bill'));
    }
  }

  Future<void> _onDeleteBill(
    DeleteBill event,
    Emitter<BillingState> emit,
  ) async {
    if (state is! BillingLoaded) return;
    final currentState = state as BillingLoaded;
    try {
      await billingService.deleteBill(event.id);
      event.onComplete.complete();
      final updatedList =
          currentState.bills.where((b) => b.id != event.id).toList();
      emit(
        BillingLoaded(
          updatedList,
          currentState.rooms,
          currentState.tenants,
          currentState.readings,
        ),
      );
    } catch (e) {
      event.onComplete.completeError(e);
      emit(BillingError('Failed to delete bill: $e'));
    }
  }
}
