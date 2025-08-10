import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/features/auth/auth_bloc.dart';
import 'package:rental_management_system_flutter/features/auth/auth_event.dart';
import 'package:rental_management_system_flutter/features/auth/auth_state.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/features/room/bloc/room_bloc.dart';
import 'package:rental_management_system_flutter/features/room/bloc/room_event.dart';
import 'package:rental_management_system_flutter/features/room/bloc/room_state.dart';
import 'package:rental_management_system_flutter/features/room/widgets/room_card.dart';
import 'package:rental_management_system_flutter/features/room/widgets/room_form_dialog.dart';
import 'package:rental_management_system_flutter/theme.dart';
import 'package:rental_management_system_flutter/utils/confirmation_action.dart';
import 'package:rental_management_system_flutter/utils/custom_add_button.dart';
import 'package:rental_management_system_flutter/utils/custom_app_bar.dart';
import 'package:rental_management_system_flutter/utils/custom_snackbar.dart';
import 'package:rental_management_system_flutter/utils/error_widget.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  late AuthBloc authBloc;
  late RoomBloc roomBloc;

  @override
  void initState() {
    super.initState();
    authBloc = context.read<AuthBloc>();
    authBloc.add(CheckAuthStatus());
    roomBloc = context.read<RoomBloc>();
    roomBloc.add(LoadRooms());
  }

  Future<void> _showRoomDialog({Room? room}) async {
    final result = await showDialog<Map<String, dynamic>?>(context: context, builder: (_) => RoomFormDialog(room: room));

    if (!mounted) return;
    if (result == null) return;

    final newRoom = Room(id: room?.id, name: result['name'] as String, rent: result['rent'] as int);

    if (room != null) {
      roomBloc.add(UpdateRoom(newRoom));
    } else {
      roomBloc.add(AddRoom(newRoom));
    }
  }

  Future<void> _confirmDelete(Room room) async {
    final messenger = ScaffoldMessenger.of(context);

    await showConfirmationAction(
      context: context,
      messenger: messenger,
      confirmTitle: 'Confirm Deletion',
      confirmContent: 'Are you sure you want to delete this room?',
      onConfirmed: () async {
        await _deleteRoom(room.id!);
      },
    );
  }

  Future<void> _deleteRoom(int id) async {
    final completer = Completer<void>();

    roomBloc.add(DeleteRoom(id, onComplete: completer));

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is Unauthenticated) {
          return buildErrorWidget(context: context, message: authState.message);
        }

        return Theme(
          data: theme,
          child: Scaffold(
            appBar: const CustomAppBar(title: 'Rooms'),
            body: BlocListener<RoomBloc, RoomState>(
              listener: (context, state) {
                if (state is RoomError) {
                  CustomSnackbar.show(context, 'Operation failed', type: SnackBarType.error);
                } else if (state is AddSuccess) {
                  CustomSnackbar.show(context, 'Room created', type: SnackBarType.success);
                } else if (state is UpdateSuccess) {
                  CustomSnackbar.show(context, 'Room updated', type: SnackBarType.success);
                } else if (state is DeleteSuccess) {
                  CustomSnackbar.show(context, 'Room deleted', type: SnackBarType.success);
                }
              },
              child: BlocBuilder<RoomBloc, RoomState>(
                builder: (context, state) {
                  if (state is RoomLoading || state is RoomInitial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is RoomError) {
                    return buildErrorWidget(context: context, message: state.message, onRetry: () => roomBloc.add(LoadRooms()));
                  } else if (state is RoomLoaded) {
                    final rooms = state.rooms;

                    if (rooms.isEmpty) {
                      return const Center(child: Text('No rooms available.'));
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = MediaQuery.of(context).size.width * 0.6;

                        return Center(
                          child: Container(
                            width: maxWidth,
                            padding: const EdgeInsets.all(16),
                            child: ListView.builder(
                              itemCount: rooms.length,
                              itemBuilder: (context, index) {
                                final room = rooms[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: RoomCard(room: room, onEdit: () => _showRoomDialog(room: room), onDelete: () => _confirmDelete(room)),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
            floatingActionButton: CustomAddButton(onPressed: () => _showRoomDialog(), label: 'New Room'),
          ),
        );
      },
    );
  }
}
