import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorPatientAppointmentsScreen extends StatefulWidget {
  final String patientId;

  const DoctorPatientAppointmentsScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<DoctorPatientAppointmentsScreen> createState() => _DoctorPatientAppointmentsScreenState();
}

class _DoctorPatientAppointmentsScreenState extends State<DoctorPatientAppointmentsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _appointments = [];
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final appointments = await _apiService.getDoctorPatientAppointments(widget.patientId);
      setState(() {
        _appointments = List<Map<String, dynamic>>.from(appointments);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final appointmentData = {
        'date': _dateController.text,
        'time': _timeController.text,
        'reason': _reasonController.text,
        'notes': _notesController.text,
      };

      await _apiService.addDoctorPatientAppointment(widget.patientId, appointmentData);
      _clearForm();
      _loadAppointments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add appointment: $e')),
        );
      }
    }
  }

  Future<void> _updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _apiService.updateDoctorPatientAppointment(widget.patientId, appointmentId, {'status': status});
      _loadAppointments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment status updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update appointment status: $e')),
        );
      }
    }
  }

  void _clearForm() {
    _dateController.clear();
    _timeController.clear();
    _reasonController.clear();
    _notesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Appointments'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _dateController,
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter date';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _timeController,
                              decoration: const InputDecoration(
                                labelText: 'Time',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter time';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _reasonController,
                              decoration: const InputDecoration(
                                labelText: 'Reason',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter reason';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                labelText: 'Notes',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter notes';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _addAppointment,
                              child: const Text('Add Appointment'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Appointment List',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = _appointments[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text('${appointment['date']} at ${appointment['time']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Reason: ${appointment['reason']}'),
                                  Text('Status: ${appointment['status']}'),
                                  if (appointment['notes'] != null)
                                    Text('Notes: ${appointment['notes']}'),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (status) {
                                  _updateAppointmentStatus(appointment['id'], status);
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'scheduled',
                                    child: Text('Scheduled'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'completed',
                                    child: Text('Completed'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'cancelled',
                                    child: Text('Cancelled'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }
} 