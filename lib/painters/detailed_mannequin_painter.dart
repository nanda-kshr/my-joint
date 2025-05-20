import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/joint.dart';

class DetailedMannequinPainter extends CustomPainter {
  final List<Joint> joints;
  final String? selectedJoint;
  
  DetailedMannequinPainter({required this.joints, this.selectedJoint});
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint bodyPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    final Paint jointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;
    
    final Paint jointOutlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
    final Paint selectedJointPaint = Paint()
      ..color = Colors.red.shade200
      ..style = PaintingStyle.fill;
    
    final Paint selectedJointOutlinePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Draw the mannequin body
    _drawMannequin(canvas, size, bodyPaint);
    
    // Draw the joints
    for (final joint in joints) {
      final Offset position = Offset(
        joint.position.dx * size.width,
        joint.position.dy * size.height,
      );
      
      double radius = joint.isFingerOrToe ? 5.0 : 10.0;
      
      if (joint.name == selectedJoint) {
        // Selected joint
        canvas.drawCircle(position, radius * 1.2, selectedJointPaint);
        canvas.drawCircle(position, radius * 1.2, selectedJointOutlinePaint);
      } else {
        // Normal joint
        canvas.drawCircle(position, radius, jointPaint);
        canvas.drawCircle(position, radius, jointOutlinePaint);
      }
    }
  }
  
  void _drawMannequin(Canvas canvas, Size size, Paint paint) {
    // Find joint positions by name
    Offset getJointPosition(String name) {
      final joint = joints.firstWhere(
        (j) => j.name == name,
        orElse: () => Joint(name, const Offset(0, 0)),
      );
      return Offset(joint.position.dx * size.width, joint.position.dy * size.height);
    }
    
    // Head and neck
    final Offset neck = getJointPosition('Neck');
    final Offset jaw = getJointPosition('Jaw');
    
    // Draw head
    canvas.drawCircle(Offset(neck.dx, neck.dy - size.height * 0.05), size.height * 0.05, paint);
    
    // Draw jaw line
    canvas.drawLine(
      Offset(jaw.dx - size.width * 0.04, jaw.dy),
      Offset(jaw.dx + size.width * 0.04, jaw.dy),
      paint
    );
    
    // Shoulders & collarbone
    final Offset rightShoulder = getJointPosition('Right Shoulder');
    final Offset leftShoulder = getJointPosition('Left Shoulder');
    final Offset rightCollarbone = getJointPosition('Right Collarbone Joint');
    final Offset leftCollarbone = getJointPosition('Left Collarbone Joint');
    
    // Connect collarbones to shoulders
    canvas.drawLine(rightCollarbone, rightShoulder, paint);
    canvas.drawLine(leftCollarbone, leftShoulder, paint);
    
    // Connect collarbones across chest
    canvas.drawLine(rightCollarbone, leftCollarbone, paint);
    
    // Connect neck to collarbones
    canvas.drawLine(neck, rightCollarbone, paint);
    canvas.drawLine(neck, leftCollarbone, paint);

    // Torso
    final Offset rightHip = getJointPosition('Right Hip');
    final Offset leftHip = getJointPosition('Left Hip');
    
    // Draw torso outline
    canvas.drawLine(rightShoulder, rightHip, paint);
    canvas.drawLine(leftShoulder, leftHip, paint);
    
    // Connect hips
    canvas.drawLine(rightHip, leftHip, paint);
    
    // Arms
    final Offset rightElbow = getJointPosition('Right Elbow');
    final Offset leftElbow = getJointPosition('Left Elbow');
    final Offset rightWrist = getJointPosition('Right Wrist');
    final Offset leftWrist = getJointPosition('Left Wrist');
    
    // Draw arms
    canvas.drawLine(rightShoulder, rightElbow, paint);
    canvas.drawLine(rightElbow, rightWrist, paint);
    canvas.drawLine(leftShoulder, leftElbow, paint);
    canvas.drawLine(leftElbow, leftWrist, paint);
    
    // SI Joints
    final Offset rightSI = getJointPosition('Right SI Joint');
    final Offset leftSI = getJointPosition('Left SI Joint');
    
    // Connect SI joints to hips
    canvas.drawLine(rightHip, rightSI, paint);
    canvas.drawLine(leftHip, leftSI, paint);
    
    // Hands and fingers
    final Offset rightKnuckle = getJointPosition('Right Knuckle'); 
    final Offset leftKnuckle = getJointPosition('Left Knuckle');
    
    // Connect wrists to knuckles
    canvas.drawLine(rightWrist, rightKnuckle, paint);
    canvas.drawLine(leftWrist, leftKnuckle, paint);
    
    // Draw fingers (simplified)
    _drawFingers(canvas, size, paint, rightKnuckle, true);
    _drawFingers(canvas, size, paint, leftKnuckle, false);
    
    // Legs
    final Offset rightKnee = getJointPosition('Right Knee');
    final Offset leftKnee = getJointPosition('Left Knee');
    final Offset rightAnkle = getJointPosition('Right Ankle');
    final Offset leftAnkle = getJointPosition('Left Ankle');
    
    // Draw legs
    canvas.drawLine(rightSI, rightKnee, paint);
    canvas.drawLine(rightKnee, rightAnkle, paint);
    canvas.drawLine(leftSI, leftKnee, paint);
    canvas.drawLine(leftKnee, leftAnkle, paint);
    
    // Draw feet and toes (simplified)
    _drawToes(canvas, size, paint, rightAnkle, true);
    _drawToes(canvas, size, paint, leftAnkle, false);
  }
  
  void _drawFingers(Canvas canvas, Size size, Paint paint, Offset knuckle, bool isRight) {
    final double directionFactor = isRight ? -1.0 : 1.0;
    final double spread = size.width * 0.04;
    final double fingerLength = size.width * 0.12;
    
    // Draw the fingers spreading out from knuckle
    for (int i = 0; i < 5; i++) {
      final double angle = i * 0.2 - 0.4; // Spread the fingers
      final Offset fingerEnd = Offset(
        knuckle.dx + directionFactor * fingerLength * cos(angle),
        knuckle.dy + fingerLength * sin(angle),
      );
      canvas.drawLine(knuckle, fingerEnd, paint);
      
      // Draw the finger joints
      final Offset midJoint = Offset(
        knuckle.dx + directionFactor * fingerLength * 0.5 * cos(angle),
        knuckle.dy + fingerLength * 0.5 * sin(angle),
      );
      
      // Draw the finger joint
      final Paint fingerJointPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
        
      final Paint fingerJointOutlinePaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
        
      canvas.drawCircle(midJoint, 4.0, fingerJointPaint);
      canvas.drawCircle(midJoint, 4.0, fingerJointOutlinePaint);
      canvas.drawCircle(fingerEnd, 4.0, fingerJointPaint);
      canvas.drawCircle(fingerEnd, 4.0, fingerJointOutlinePaint);
    }
  }
  
  void _drawToes(Canvas canvas, Size size, Paint paint, Offset ankle, bool isRight) {
    final double footLength = size.width * 0.2;
    final double footWidth = size.width * 0.06;
    
    // Draw foot
    final Offset footEnd = Offset(ankle.dx, ankle.dy + footLength);
    
    // Draw the main foot outline
    final Path footPath = Path();
    footPath.moveTo(ankle.dx - footWidth / 2, ankle.dy);
    footPath.lineTo(ankle.dx - footWidth / 2, footEnd.dy - footWidth / 3);
    footPath.lineTo(ankle.dx + footWidth / 2, footEnd.dy - footWidth / 3);
    footPath.lineTo(ankle.dx + footWidth / 2, ankle.dy);
    canvas.drawPath(footPath, paint);
    
    // Draw toes
    final double toesStartY = footEnd.dy - footWidth / 3;
    final double toeWidth = footWidth / 6;
    
    for (int i = 0; i < 5; i++) {
      final double toeX = ankle.dx - footWidth / 2 + toeWidth * (i + 0.5);
      final Offset toeStart = Offset(toeX, toesStartY);
      final Offset toeEnd = Offset(toeX, toesStartY + footWidth / 3);
      canvas.drawLine(toeStart, toeEnd, paint);
      
      // Draw the toe joint
      final Paint toeJointPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
        
      final Paint toeJointOutlinePaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
        
      canvas.drawCircle(toeEnd, 3.0, toeJointPaint);
      canvas.drawCircle(toeEnd, 3.0, toeJointOutlinePaint);
    }
  }
  
  @override
  bool shouldRepaint(DetailedMannequinPainter oldDelegate) {
    return oldDelegate.selectedJoint != selectedJoint;
  }
  
  // Helper function to get the angle between two points
  double _getAngle(Offset start, Offset end) {
    return (end - start).direction;
  }
  
  // Helper function to calculate cosine
  double cos(double angle) {
    return math.cos(angle);
  }
  
  // Helper function to calculate sine
  double sin(double angle) {
    return math.sin(angle);
  }
}