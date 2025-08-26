import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorMessageScreen extends StatefulWidget {
  final String complaint;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const DoctorMessageScreen({
    Key? key,
    required this.complaint,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  State<DoctorMessageScreen> createState() => _DoctorMessageScreenState();
}

class _DoctorMessageScreenState extends State<DoctorMessageScreen> {
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { _selectedLanguage = prefs.getString('language') ?? 'en'; });
  }

  @override
  Widget build(BuildContext context) {
    final isEn = _selectedLanguage == 'en';
    return AlertDialog(
      title: Text(isEn ? 'Patient Complaint' : 'ரோகி புகார்'),
      content: Text(widget.complaint),
      actions: [
        TextButton(
          onPressed: widget.onReject,
          child: Text(isEn ? 'Reject' : 'நிராகரி', style: const TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: widget.onApprove,
          child: Text(isEn ? 'Approve' : 'அனுமதி'),
        ),
      ],
    );
  }
}
