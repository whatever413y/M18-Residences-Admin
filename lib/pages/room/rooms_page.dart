import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/pages/room/bloc/room_bloc.dart';
import 'package:rental_management_system_flutter/pages/room/bloc/room_event.dart';
import 'package:rental_management_system_flutter/pages/room/bloc/room_state.dart';
import 'package:rental_management_system_flutter/pages/room/widgets/room_card.dart';
import 'package:rental_management_system_flutter/pages/room/widgets/room_form_dialog.dart';
import 'package:rental_management_system_flutter/theme.dart';
import 'package:rental_management_system_flutter/utils/confirmation_action.dart';
import 'package:rental_management_system_flutter/utils/custom_add_button.dart';
import 'package:rental_management_system_flutter/utils/custom_app_bar.dart';
import 'package:rental_management_system_flutter/utils/custom_snackbar.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  Future<void> _showRoomDialog({Room? room}) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (_) => RoomFormDialog(room: room),
    );

    if (!mounted) return;

    if (result == null) return;

    final bloc = context.read<RoomBloc>();

    CustomSnackbar.show(
      context,
      room != null ? 'Updating...' : 'Creating...',
      type: SnackBarType.loading,
    );

    try {
      if (room != null) {
        bloc.add(
          UpdateRoom(
            Room(
              id: room.id,
              name: result['name'] as String,
              rent: result['rent'] as int,
            ),
          ),
        );
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          'Room updated',
          type: SnackBarType.success,
        );
      } else {
        bloc.add(
          AddRoom(
            Room(name: result['name'] as String, rent: result['rent'] as int),
          ),
        );
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          'Room "${result['name']}" added',
          type: SnackBarType.success,
        );
      }
    } catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        'Operation failed',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _confirmDelete(Room room) async {
    final messenger = ScaffoldMessenger.of(context);

    await showConfirmationAction(
      context: context,
      messenger: messenger,
      confirmTitle: 'Confirm Deletion',
      confirmContent: 'Are you sure you want to delete this room?',
      loadingMessage: 'Deleting room...',
      successMessage: 'Room deleted successfully',
      failureMessage: 'Failed to delete room',
      onConfirmed: () async {
        context.read<RoomBloc>().add(DeleteRoom(room.id!));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Rooms'),
        body: BlocBuilder<RoomBloc, RoomState>(
          builder: (context, state) {
            if (state is RoomLoading || state is RoomInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RoomError) {
              return Center(child: Text(state.message));
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
                            child: RoomCard(
                              room: room,
                              onEdit: () => _showRoomDialog(room: room),
                              onDelete: () => _confirmDelete(room),
                            ),
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
        floatingActionButton: CustomAddButton(
          onPressed: () => _showRoomDialog(),
          label: 'New Room',
        ),
      ),
    );
  }
}
