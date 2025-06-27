import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorTimeSlotsScreen extends StatefulWidget {
  const DoctorTimeSlotsScreen({super.key});

  @override
  State<DoctorTimeSlotsScreen> createState() => _DoctorTimeSlotsScreenState();
}

class _DoctorTimeSlotsScreenState extends State<DoctorTimeSlotsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _timeSlots = [];
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _loadTimeSlots();
  }

  Future<void> _loadTimeSlots() async {
    try {
      final timeSlots = await _apiService.getDoctorTimeSlots();
      setState(() {
        _timeSlots = List<Map<String, dynamic>>.from(timeSlots);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addTimeSlot() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final timeSlotData = {
        'date': _selectedDate.toIso8601String().split('T')[0],
        'slots': [
          {
            'startTime': _startTimeController.text,
            'endTime': _endTimeController.text,
          }
        ],
      };

      await _apiService.addDoctorTimeSlot(timeSlotData);
      _startTimeController.clear();
      _endTimeController.clear();
      _loadTimeSlots();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time slot added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add time slot: $e')),
        );
      }
    }
  }

  Future<void> _updateTimeSlotStatus(String slotId, bool isAvailable) async {
    try {
      await _apiService.updateDoctorTimeSlot(slotId, isAvailable);
      _loadTimeSlots();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time slot updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update time slot: $e')),
        );
      }
    }
  }

  Future<void> _deleteTimeSlot(String slotId) async {
    try {
      await _apiService.deleteDoctorTimeSlot(slotId);
      _loadTimeSlots();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time slot deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete time slot: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Time Slots'),
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
                            InkWell(
                              onTap: _selectDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _startTimeController,
                              decoration: const InputDecoration(
                                labelText: 'Start Time (HH:mm)',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter start time';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _endTimeController,
                              decoration: const InputDecoration(
                                labelText: 'End Time (HH:mm)',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter end time';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _addTimeSlot,
                              child: const Text('Add Time Slot'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Your Time Slots',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _timeSlots.length,
                        itemBuilder: (context, index) {
                          final slot = _timeSlots[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text('${slot['startTime']} - ${slot['endTime']}'),
                              subtitle: Text('Date: ${slot['date']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      slot['isAvailable']
                                          ? Icons.block
                                          : Icons.check_circle,
                                    ),
                                    onPressed: () => _updateTimeSlotStatus(
                                      slot['id'],
                                      !slot['isAvailable'],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteTimeSlot(slot['id']),
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
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }
} 