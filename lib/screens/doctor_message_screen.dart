import 'package:flutter/material.dart';

class DoctorMessageScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Patient Complaint'),
      content: Text(complaint),
      actions: [
        TextButton(
          onPressed: onReject,
          child: const Text('Reject', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: onApprove,
          child: const Text('Approve'),
        ),
      ],
    );
  }
}
