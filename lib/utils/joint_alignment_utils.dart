import 'dart:convert';
import '../models/joint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JointAlignmentUtils {
  // Export joint positions to clipboard in JSON format
  static void exportJointPositions(List<Joint> joints, BuildContext context) {
    final List<Map<String, dynamic>> jointData = joints.map((joint) => {
      'name': joint.name,
      'positionX': joint.position.dx,
      'positionY': joint.position.dy,
      'isFingerOrToe': joint.isFingerOrToe,
    }).toList();
    
    final String jsonData = jsonEncode(jointData);
    
    Clipboard.setData(ClipboardData(text: jsonData)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Joint positions copied to clipboard as JSON'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
  
  // Import joint positions from JSON string
  static List<Joint>? importJointPositions(String jsonString) {
    try {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      
      return jsonData.map((jointMap) {
        return Joint(
          jointMap['name'], 
          Offset(jointMap['positionX'], jointMap['positionY']),
          isFingerOrToe: jointMap['isFingerOrToe'] ?? false,
        );
      }).toList();
    } catch (e) {
      print('Error importing joint positions: $e');
      return null;
    }
  }
}