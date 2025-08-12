import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class HealthRecordsScreen extends StatefulWidget {
  final dynamic patientUid;
  const HealthRecordsScreen({Key? key, required this.patientUid}) : super(key: key);

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  late ApiService _apiService;
  List<dynamic> _records = [];
  bool _isLoading = false;
  int? _patientId;
  String? _userType;

  @override
  void initState() {
    super.initState();
    _initApi();
  }

  Future<void> _initApi() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _userType = await _apiService.getUserType();
    if (widget.patientUid is int) {
      _patientId = widget.patientUid;
    } else if (widget.patientUid is String) {
      _patientId = int.tryParse(widget.patientUid);
    } else {
      _patientId = null;
    }
    if (_patientId != null) {
      _fetchRecords();
    }
    setState(() {});
  }

  Future<void> _fetchRecords() async {
    if (_patientId == null) return;
    setState(() => _isLoading = true);
    try {
      final files = await _apiService.getPatientFiles(patientId: _patientId!);
      setState(() {
        _records = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch records: $e')),
      );
    }
  }

  Future<void> _downloadRecord(Map record) async {
    try {
      final response = await _apiService.downloadPatientFile(storedFilename: record['stored_filename']);
      // Save file to device (for demo, just show a snackbar)
      // You can use path_provider and open_file for real download
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded: ${record['original_filename']}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }

  Future<void> _uploadRecord() async {
    if (_patientId == null) return;
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: false,
    );
    if (result != null && result.files.single.size < 10 * 1024 * 1024) {
      final file = result.files.single;
      try {
        await _apiService.uploadPatientFile(
          patientId: _patientId!,
          filePath: file.path!,
          fileName: file.name,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF uploaded successfully!')),
        );
        _fetchRecords();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } else if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File size must be less than 10MB.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
        actions: [
          if (_userType == 'doctor' || _userType == 'patient')
            IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: _uploadRecord,
              tooltip: 'Upload PDF',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? const Center(child: Text('No health records found.'))
              : ListView.builder(
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    return ListTile(
                      leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                      title: Text(record['original_filename'] ?? ''),
                      subtitle: Text('Uploaded: ${record['uploaded_at'] ?? ''}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () => _downloadRecord(record),
                        tooltip: 'Download',
                      ),
                    );
                  },
                ),
    );
  }
}
