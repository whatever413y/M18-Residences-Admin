import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/pages/room/bloc/room_bloc.dart';
import 'package:rental_management_system_flutter/pages/room/bloc/room_event.dart';
import 'package:rental_management_system_flutter/pages/tenants/bloc/tenant_bloc.dart';
import 'package:rental_management_system_flutter/pages/tenants/bloc/tenant_event.dart';
import 'package:rental_management_system_flutter/services/room_service.dart';
import 'package:rental_management_system_flutter/services/tenant_service.dart';

final List<BlocProvider> blocProviders = [
  BlocProvider<RoomBloc>(
    create: (_) => RoomBloc(RoomService())..add(LoadRooms()),
  ),
  BlocProvider<TenantBloc>(
    create:
        (_) => TenantBloc(
          tenantService: TenantService(),
          roomService: RoomService(),
        )..add(LoadTenants()),
  ),
];
