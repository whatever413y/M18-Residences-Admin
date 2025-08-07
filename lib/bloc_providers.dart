import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/features/auth/auth_bloc.dart';
import 'package:rental_management_system_flutter/pages/billing/bloc/billing_bloc.dart';
import 'package:rental_management_system_flutter/pages/billing/bloc/billing_event.dart';
import 'package:rental_management_system_flutter/pages/reading/bloc/reading_bloc.dart';
import 'package:rental_management_system_flutter/pages/reading/bloc/reading_event.dart';
import 'package:rental_management_system_flutter/pages/room/bloc/room_bloc.dart';
import 'package:rental_management_system_flutter/pages/room/bloc/room_event.dart';
import 'package:rental_management_system_flutter/pages/tenants/bloc/tenant_bloc.dart';
import 'package:rental_management_system_flutter/pages/tenants/bloc/tenant_event.dart';
import 'package:rental_management_system_flutter/services/auth_service.dart';
import 'package:rental_management_system_flutter/services/billing_service.dart';
import 'package:rental_management_system_flutter/services/reading_service.dart';
import 'package:rental_management_system_flutter/services/room_service.dart';
import 'package:rental_management_system_flutter/services/tenant_service.dart';

final List<BlocProvider> blocProviders = [
  BlocProvider<AuthBloc>(create: (_) => AuthBloc(authService: AuthService())),
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
