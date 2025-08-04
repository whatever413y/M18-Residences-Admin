import 'package:flutter/material.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/pages/room/widgets/room_card.dart';
import 'package:rental_management_system_flutter/pages/room/widgets/room_form_dialog.dart';
import 'package:rental_management_system_flutter/utils/confirmation_action.dart';
import 'package:rental_management_system_flutter/utils/custom_add_button.dart';
import 'package:rental_management_system_flutter/utils/custom_app_bar.dart';
import 'package:rental_management_system_flutter/utils/custom_snackbar.dart';
import '../../services/room_service.dart';
import 'package:rental_management_system_flutter/theme.dart';

class RoomsPage extends StatefulWidget {
  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final RoomService _roomService = RoomService();
  List<Room> _rooms = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => _isLoading = true);
    try {
      final rooms = await _roomService.fetchRooms();
      if (!mounted) return;
      setState(() => _rooms = rooms);
    } catch (e) {
      debugPrint('Error loading rooms: $e');
      if (mounted) {
        CustomSnackbar.show(
          context,
          'Failed to load rooms',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRoomDialog({Room? room}) {
    showDialog(
      context: context,
      builder:
          (_) => RoomFormDialog(
            room: room,
            onSubmit: (name, rent) async {
              try {
                if (mounted) {
                  CustomSnackbar.show(
                    context,
                    room != null ? 'Updating...' : 'Creating...',
                    type: SnackBarType.loading,
                    dismissPrevious: true,
                  );
                }

                if (room != null) {
                  await _roomService.updateRoom(room.id, name, rent);
                  if (mounted) {
                    CustomSnackbar.show(
                      context,
                      'Room updated',
                      type: SnackBarType.success,
                    );
                  }
                } else {
                  await _roomService.createRoom(name, rent);
                  if (mounted) {
                    CustomSnackbar.show(
                      context,
                      'Room "$name" added',
                      type: SnackBarType.success,
                    );
                  }
                }

                await _loadRooms();
              } catch (_) {
                if (mounted) {
                  CustomSnackbar.show(
                    context,
                    'Operation failed',
                    type: SnackBarType.error,
                  );
                }
              } finally {
                if (mounted) CustomSnackbar.hide(context);
              }
            },
          ),
    );
  }

  Future<void> _deleteRoom(int id) async {
    await _roomService.deleteRoom(id);
    if (!mounted) return;
    await _loadRooms();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Rooms'),
        body: RefreshIndicator(
          onRefresh: _loadRooms,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double maxWidth =
                  constraints.maxWidth > 600 ? 600 : constraints.maxWidth;

              return Center(
                child: Container(
                  width: maxWidth,
                  padding: const EdgeInsets.all(16),
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _rooms.isEmpty
                          ? const Center(child: Text('No rooms available.'))
                          : ListView.builder(
                            itemCount: _rooms.length,
                            itemBuilder: (context, index) {
                              final room = _rooms[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: RoomCard(
                                  room: room,
                                  onEdit: () => _showRoomDialog(room: room),
                                  onDelete: () async {
                                    await showConfirmationAction(
                                      context: context,
                                      confirmTitle: 'Confirm Deletion',
                                      confirmContent:
                                          'Are you sure you want to delete this room?',
                                      loadingMessage: 'Deleting...',
                                      successMessage: 'Room deleted',
                                      failureMessage: 'Failed to delete room',
                                      onConfirmed: () async {
                                        await _deleteRoom(room.id);
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                ),
              );
            },
          ),
        ),
        floatingActionButton: CustomAddButton(
          onPressed: () => _showRoomDialog(),
          label: 'New Room',
        ),
      ),
    );
  }
}
