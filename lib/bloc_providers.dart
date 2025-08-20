import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m18_residences_admin/features/auth/auth_bloc.dart';
import 'package:m18_residences_admin/features/auth/auth_event.dart';
import 'package:m18_residences_admin/features/billing/bloc/billing_bloc.dart';
import 'package:m18_residences_admin/features/billing/bloc/billing_event.dart';
import 'package:m18_residences_admin/features/reading/bloc/reading_bloc.dart';
import 'package:m18_residences_admin/features/reading/bloc/reading_event.dart';
import 'package:m18_residences_admin/features/room/bloc/room_bloc.dart';
import 'package:m18_residences_admin/features/room/bloc/room_event.dart';
import 'package:m18_residences_admin/features/tenants/bloc/tenant_bloc.dart';
import 'package:m18_residences_admin/features/tenants/bloc/tenant_event.dart';
import 'package:m18_residences_admin/services/auth_service.dart';
import 'package:m18_residences_admin/services/billing_service.dart';
import 'package:m18_residences_admin/services/reading_service.dart';
import 'package:m18_residences_admin/services/room_service.dart';
import 'package:m18_residences_admin/services/tenant_service.dart';

final List<BlocProvider> blocProviders = [
  BlocProvider<AuthBloc>(create: (_) => AuthBloc(authService: AuthService())..add(CheckAuthStatus())),
  BlocProvider<RoomBloc>(create: (_) => RoomBloc(RoomService())..add(LoadRooms())),
  BlocProvider<TenantBloc>(create: (_) => TenantBloc(tenantService: TenantService(), roomService: RoomService())..add(LoadTenants())),
  BlocProvider<ReadingBloc>(
    create: (_) => ReadingBloc(readingService: ReadingService(), roomService: RoomService(), tenantService: TenantService())..add(LoadReadings()),
  ),
  BlocProvider<BillingBloc>(
    create:
        (_) => BillingBloc(
          readingService: ReadingService(),
          roomService: RoomService(),
          tenantService: TenantService(),
          billingService: BillingService(),
        )..add(LoadBills()),
  ),
];
