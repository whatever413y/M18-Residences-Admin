import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/pages/room/bloc/room_bloc.dart';
import 'package:rental_management_system_flutter/pages/room/bloc/room_event.dart';
import 'package:rental_management_system_flutter/services/room_service.dart';

final blocProviders = [
  BlocProvider(create: (_) => RoomBloc(RoomService())..add(LoadRooms())),
  // BlocProvider(create: (_) => TenantBloc(TenantService())..add(LoadTenants())),
];
