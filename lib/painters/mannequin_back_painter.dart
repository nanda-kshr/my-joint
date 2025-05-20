import 'package:flutter/material.dart';
import '../models/joint.dart';

class MannequinBackPainter extends CustomPainter {
  final List<Joint> joints;
  final String? selectedJoint;
  
  MannequinBackPainter({required this.joints, this.selectedJoint});
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint bodyPaint = Paint()
      ..color = Colors.blue[100]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    final Paint jointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
      
    final Paint selectedJointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    // Draw the mannequin body (back view)
    _drawMannequin(canvas, size, bodyPaint);
    
    // Draw the joints
    for (final joint in joints) {
      final Offset position = Offset(
        joint.position.dx * size.width,
        joint.position.dy * size.height,
      );
      
      canvas.drawCircle(
        position, 
        joint.name == selectedJoint ? 12.0 : 8.0, 
        joint.name == selectedJoint ? selectedJointPaint : jointPaint
      );
    }
  }
  
  void _drawMannequin(Canvas canvas, Size size, Paint paint) {
    // Find joint positions by name
    Offset getJointPosition(String name) {
      final joint = joints.firstWhere((j) => j.name == name);
      return Offset(joint.position.dx * size.width, joint.position.dy * size.height);
    }
    
    // Head
    final Offset neck = getJointPosition('Neck');
    canvas.drawCircle(Offset(neck.dx, neck.dy - size.height * 0.05), size.height * 0.05, paint);
    
    // Torso - for back view, adjust the shape slightly
    final Offset rightShoulder = getJointPosition('Right Shoulder');
    final Offset leftShoulder = getJointPosition('Left Shoulder');
    final Offset rightHip = getJointPosition('Right Hip');
    final Offset leftHip = getJointPosition('Left Hip');
    final Offset lowerBack = getJointPosition('Lower Back');
    
    // Draw torso outline
    final Path torsoPath = Path()
      ..moveTo(rightShoulder.dx, rightShoulder.dy)
      ..lineTo(leftShoulder.dx, leftShoulder.dy)
      ..lineTo(leftHip.dx, leftHip.dy)
      ..lineTo(rightHip.dx, rightHip.dy)
      ..close();
    canvas.drawPath(torsoPath, paint);
    
    // Connect neck to shoulders
    canvas.drawLine(neck, rightShoulder, paint);
    canvas.drawLine(neck, leftShoulder, paint);
    
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
    
    // Legs
    final Offset rightKnee = getJointPosition('Right Knee');
    final Offset leftKnee = getJointPosition('Left Knee');
    final Offset rightAnkle = getJointPosition('Right Ankle');
    final Offset leftAnkle = getJointPosition('Left Ankle');
    
    // Draw legs
    canvas.drawLine(rightHip, rightKnee, paint);
    canvas.drawLine(rightKnee, rightAnkle, paint);
    canvas.drawLine(leftHip, leftKnee, paint);
    canvas.drawLine(leftKnee, leftAnkle, paint);
  }
  
  @override
  bool shouldRepaint(MannequinBackPainter oldDelegate) {
    return oldDelegate.selectedJoint != selectedJoint;
  }
}