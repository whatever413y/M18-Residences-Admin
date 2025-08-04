import 'package:flutter/material.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/pages/room/widgets/room_card.dart';
import 'package:rental_management_system_flutter/pages/room/widgets/room_form_dialog.dart';
import 'package:rental_management_system_flutter/utils/custom_add_button.dart';
import 'package:rental_management_system_flutter/utils/custom_app_bar.dart';
import 'package:rental_management_system_flutter/utils/custom_snackbar.dart';
import '../../services/room_service.dart';

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this room?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        if (mounted) {
          CustomSnackbar.show(
            context,
            'Deleting...',
            type: SnackBarType.loading,
          );
        }

        await _roomService.deleteRoom(id);

        if (mounted) {
          CustomSnackbar.show(
            context,
            'Room deleted',
            type: SnackBarType.success,
          );
        }

        await _loadRooms();
      } catch (e) {
        if (mounted) {
          CustomSnackbar.show(
            context,
            'Failed to delete room',
            type: SnackBarType.error,
          );
        }
      } finally {
        if (mounted) CustomSnackbar.hide(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Rooms'),
      body: RefreshIndicator(
        onRefresh: _loadRooms,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _rooms.isEmpty
                  ? const Center(child: Text('No rooms available.'))
                  : ListView.builder(
                    itemCount: _rooms.length,
                    itemBuilder: (context, index) {
                      final room = _rooms[index];
                      return RoomCard(
                        room: room,
                        onEdit: () => _showRoomDialog(room: room),
                        onDelete: () => _deleteRoom(room.id),
                      );
                    },
                  ),
        ),
      ),
      floatingActionButton: CustomAddButton(
        onPressed: () => _showRoomDialog(),
        label: 'New Room',
      ),
    );
  }
}
