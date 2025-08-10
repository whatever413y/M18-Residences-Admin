import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/features/tenants/bloc/tenant_event.dart';
import 'package:rental_management_system_flutter/features/tenants/bloc/tenant_state.dart';
import 'package:rental_management_system_flutter/services/tenant_service.dart';
import 'package:rental_management_system_flutter/services/room_service.dart';

class TenantBloc extends Bloc<TenantEvent, TenantState> {
  final TenantService tenantService;
  final RoomService roomService;

  TenantBloc({required this.tenantService, required this.roomService}) : super(TenantInitial()) {
    on<LoadTenants>(_onLoadTenants);
    on<AddTenant>(_onAddTenant);
    on<UpdateTenantEvent>(_onUpdateTenant);
    on<DeleteTenant>(_onDeleteTenant);
  }

  Future<void> _onLoadTenants(LoadTenants event, Emitter<TenantState> emit) async {
    emit(TenantLoading());
    try {
      final tenants = await tenantService.fetchTenants();
      final rooms = await roomService.fetchRooms();
      emit(TenantLoaded(tenants, rooms));
    } catch (e) {
      emit(TenantError('Failed to load tenants'));
    }
  }

  Future<void> _onAddTenant(AddTenant event, Emitter<TenantState> emit) async {
    try {
      await tenantService.createTenant(event.tenant.name, event.tenant.roomId, event.tenant.joinDate);
      add(LoadTenants());
      emit(AddSuccess());
    } catch (e) {
      emit(TenantError('Failed to add tenant'));
    }
  }

  Future<void> _onUpdateTenant(UpdateTenantEvent event, Emitter<TenantState> emit) async {
    try {
      await tenantService.updateTenant(event.tenant.id!, event.tenant.name, event.tenant.roomId, event.tenant.joinDate, event.tenant.isActive);
      add(LoadTenants());
      emit(UpdateSuccess());
    } catch (e) {
      emit(TenantError('Failed to update tenant'));
    }
  }

  Future<void> _onDeleteTenant(DeleteTenant event, Emitter<TenantState> emit) async {
    try {
      await tenantService.deleteTenant(event.id);
      event.onComplete.complete();
      add(LoadTenants());
      emit(DeleteSuccess());
    } catch (e) {
      event.onComplete.completeError(e);
      emit(TenantError('Failed to delete tenant: $e'));
    }
  }
}
