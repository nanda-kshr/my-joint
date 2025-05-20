import 'package:flutter/material.dart';

class Joint {
  final String name;
  final Offset position; // Normalized coordinates (0-1)
  final bool isFingerOrToe; // Used to determine if we draw it smaller
  
  Joint(this.name, this.position, {this.isFingerOrToe = false});
}