import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() =>
      _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Map<String, dynamic>> _appointments = [];
  bool _loading = true;
  bool _saving = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAppointments();

    // Refresh appointments while this screen is open.
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _loadAppointments(showLoading: false),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAppointments({
    bool showLoading = true,
  }) async {
    if (showLoading && mounted) {
      setState(() => _loading = true);
    }

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/appointments'),
        headers: await authHeaders(),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          setState(() {
            _appointments = data
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
          });
        }
      } else {
        _showMessage(
          response.statusCode == 401
              ? 'Please sign in again.'
              : 'Could not load appointments.',
        );
      }
    } catch (e) {
      debugPrint('Appointment loading error: $e');
      if (mounted && showLoading) {
        _showMessage('Cannot connect to the PregEase server.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openAppointmentForm({
    Map<String, dynamic>? appointment,
  }) async {
    final titleController = TextEditingController(
      text: appointment?['title']?.toString() ?? '',
    );
    final locationController = TextEditingController(
      text: appointment?['location']?.toString() ?? '',
    );
    final notesController = TextEditingController(
      text: appointment?['notes']?.toString() ?? '',
    );

    final existingDate = appointment?['appointment_date'] != null
        ? DateTime.tryParse(
            appointment!['appointment_date'].toString(),
          )?.toLocal()
        : null;

    DateTime selectedDate = existingDate ?? DateTime.now();
    TimeOfDay selectedTime = existingDate != null
        ? TimeOfDay.fromDateTime(existingDate)
        : TimeOfDay.now();

    DateTime? reminderDate = appointment?['reminder_at'] != null
        ? DateTime.tryParse(
            appointment!['reminder_at'].toString(),
          )?.toLocal()
        : null;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                appointment == null
                    ? 'Add appointment'
                    : 'Edit appointment',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Appointment title *',
                        hintText: 'e.g. Pregnancy checkup',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('Date'),
                      subtitle: Text(
                        '${selectedDate.day.toString().padLeft(2, '0')}/'
                        '${selectedDate.month.toString().padLeft(2, '0')}/'
                        '${selectedDate.year}',
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                            );
                          });
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time),
                      title: const Text('Time'),
                      subtitle: Text(selectedTime.format(context)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setDialogState(() => selectedTime = picked);
                        }
                      },
                    ),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.notifications_outlined),
                      title: const Text('Reminder'),
                      subtitle: Text(
                        reminderDate == null
                            ? 'No reminder selected'
                            : reminderDate!.toLocal().toString().substring(0, 16),
                      ),
                      trailing: reminderDate == null
                          ? null
                          : IconButton(
                              tooltip: 'Remove reminder',
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setDialogState(() => reminderDate = null);
                              },
                            ),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: reminderDate ?? selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate == null || !context.mounted) return;

                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: reminderDate != null
                              ? TimeOfDay.fromDateTime(reminderDate!)
                              : selectedTime,
                        );

                        if (pickedTime != null) {
                          setDialogState(() {
                            reminderDate = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          if (title.isEmpty) {
                            _showMessage('Enter an appointment title.');
                            return;
                          }

                          final appointmentDate = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );

                          if (reminderDate != null &&
                              reminderDate!.isAfter(appointmentDate)) {
                            _showMessage(
                              'Reminder must be before the appointment.',
                            );
                            return;
                          }

                          final payload = {
                            'title': title,
                            'appointment_date':
                                appointmentDate.toIso8601String(),
                            'location': locationController.text.trim(),
                            'notes': notesController.text.trim(),
                            'reminder_at':
                                reminderDate?.toIso8601String(),
                          };

                          final success = await _saveAppointment(
                            payload,
                            id: appointment?['id'],
                          );

                          if (success && dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                  child: Text(
                    appointment == null ? 'Create' : 'Save changes',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    locationController.dispose();
    notesController.dispose();
  }

  Future<bool> _saveAppointment(
    Map<String, dynamic> payload, {
    dynamic id,
  }) async {
    setState(() => _saving = true);

    try {
      final isEditing = id != null;
      final response = isEditing
          ? await http.put(
              Uri.parse('$apiBaseUrl/appointments/$id'),
              headers: await authHeaders(),
              body: jsonEncode(payload),
            )
          : await http.post(
              Uri.parse('$apiBaseUrl/appointments'),
              headers: await authHeaders(),
              body: jsonEncode(payload),
            );

      if (!mounted) return false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _loadAppointments();
        if (mounted) {
          _showMessage(
            isEditing ? 'Appointment updated.' : 'Appointment created.',
          );
        }
        return true;
      }

      _showMessage(_responseError(response));
      return false;
    } catch (e) {
      debugPrint('Appointment save error: $e');
      if (mounted) _showMessage('Could not save appointment.');
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _responseError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['detail'] != null) {
        return data['detail'].toString();
      }
    } catch (_) {}
    return 'Request failed (${response.statusCode}).';
  }

  Future<void> _cancelAppointment(
    Map<String, dynamic> appointment,
  ) async {
    final id = appointment['id'];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel appointment?'),
        content: Text('Cancel "${appointment['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel appointment'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/appointments/$id/cancel'),
        headers: await authHeaders(),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        await _loadAppointments();
        _showMessage('Appointment cancelled.');
      } else {
        _showMessage(_responseError(response));
      }
    } catch (e) {
      debugPrint('Appointment cancellation error: $e');
      if (mounted) _showMessage('Could not cancel appointment.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (date == null) return 'Date unavailable';
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day}/${date.month}/${date.year} · $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF343A33);
    const coral = Color(0xFFFF7867);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          IconButton(
            tooltip: 'Refresh appointments',
            onPressed: () => _loadAppointments(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAppointmentForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add appointment'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
        child: _loading
            ?  ListView(
                children: [
                  SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              )
            : _appointments.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    children: const [
                      SizedBox(height: 70),
                      Icon(
                        Icons.event_available_rounded,
                        size: 72,
                        color: Color(0xFF71866B),
                      ),
                      SizedBox(height: 18),
                      Text(
                        'No appointments yet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: ink,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add a checkup or important date so you can plan together.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = _appointments[index];
                      final status =
                          appointment['status']?.toString() ?? 'scheduled';
                      final cancelled = status == 'cancelled';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Color(0xFFFFE9DE),
                                    child: Icon(
                                      Icons.calendar_month_rounded,
                                      color: coral,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      appointment['title']?.toString() ??
                                          'Appointment',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: ink,
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _openAppointmentForm(
                                          appointment: appointment,
                                        );
                                      } else if (value == 'cancel') {
                                        _cancelAppointment(appointment);
                                      } else if (value == 'complete') {
                                        _saveAppointment({
                                          'status': 'completed',
                                        }, id: appointment['id']);
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      if (!cancelled &&
                                          status != 'completed')
                                        const PopupMenuItem(
                                          value: 'complete',
                                          child: Text('Mark completed'),
                                        ),
                                      if (!cancelled &&
                                          status != 'completed')
                                        const PopupMenuItem(
                                          value: 'cancel',
                                          child: Text('Cancel appointment'),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(_formatDate(appointment['appointment_date'])),
                              if ((appointment['location'] ?? '')
                                  .toString()
                                  .trim()
                                  .isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text('Location: ${appointment['location']}'),
                              ],
                              if ((appointment['notes'] ?? '')
                                  .toString()
                                  .trim()
                                  .isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text('Notes: ${appointment['notes']}'),
                              ],
                              const SizedBox(height: 10),
                              Chip(
                                label: Text(
                                  status[0].toUpperCase() + status.substring(1),
                                ),
                                backgroundColor: cancelled
                                    ? Colors.grey.shade200
                                    : status == 'completed'
                                        ? const Color(0xFFDDF4E7)
                                        : const Color(0xFFFFE9DE),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
