import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/joint.dart';

class SimplifiedMannequinPainter extends CustomPainter {
  final List<Joint> joints;
  final String? selectedJoint;
  final bool drawJointsOnly;
  
  SimplifiedMannequinPainter({
    required this.joints,
    this.selectedJoint,
    this.drawJointsOnly = false,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint bodyPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    final Paint jointPaint = Paint()
      ..color = const Color.fromARGB(255, 130, 50, 50)
      ..style = PaintingStyle.fill;
    
    final Paint jointOutlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final Paint selectedJointFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final Paint selectedJointOutlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Draw the mannequin body lines first (stick figure) - optional
    if (!drawJointsOnly) {
      _drawMannequinLines(canvas, size, bodyPaint);
    }
    
    // Draw all joints
    for (final joint in joints) {
      final Offset position = Offset(
        joint.position.dx * size.width,
        joint.position.dy * size.height,
      );
      
      bool isSelected = joint.name == selectedJoint;
      
      // Get joint size based on type
      double width = joint.isFingerOrToe ? 10.0 : 25.0;
      double height = joint.isFingerOrToe ? 10.0 : 25.0;
      
      // For knees, wrists, and ankles, make the ellipses wider
      if (['Right Knee', 'Left Knee', 'Right Wrist', 'Left Wrist', 
           'Right Ankle', 'Left Ankle'].contains(joint.name)) {
        width = 30.0;
        height = 30.0;
      }
      
      // For shoulders, make them taller ellipses
      if (['Right Shoulder', 'Left Shoulder'].contains(joint.name)) {
        width = 20.0;
        height = 20.0;
      }
      
      // Draw the joint ellipse
      _drawJointEllipse(
        canvas, 
        position, 
        width, 
        height, 
        isSelected ? selectedJointFillPaint : jointPaint, 
        isSelected ? selectedJointOutlinePaint : jointOutlinePaint
      );
      
      // If selected, draw a checkmark inside the joint
      if (isSelected) {
        _drawCheckmark(canvas, position);
        
        // Draw directional arrows for selected joints like in the reference
        if (['Right Wrist', 'Left Wrist', 'Right Knee', 'Left Knee'].contains(joint.name)) {
          _drawDirectionalArrows(canvas, position, joint.name);
        }
      }
    }
  }
  
  void _drawJointEllipse(Canvas canvas, Offset center, double width, double height, 
                         Paint fillPaint, Paint strokePaint) {
    final rect = Rect.fromCenter(
      center: center,
      width: width,
      height: height
    );
    
    canvas.drawOval(rect, fillPaint);
    canvas.drawOval(rect, strokePaint);
  }
  
  void _drawCheckmark(Canvas canvas, Offset center) {
    final Paint checkmarkPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    final Path checkmarkPath = Path()
      ..moveTo(center.dx - 5, center.dy)
      ..lineTo(center.dx - 2, center.dy + 3)
      ..lineTo(center.dx + 5, center.dy - 4);
    
    canvas.drawPath(checkmarkPath, checkmarkPaint);
  }
  
  void _drawDirectionalArrows(Canvas canvas, Offset center, String jointName) {
    final Paint arrowPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
      
    // Arrow direction depends on the joint
    double angleOffset = 0;
    if (jointName == 'Right Wrist') angleOffset = -math.pi / 4;
    if (jointName == 'Left Wrist') angleOffset = -3 * math.pi / 4;
    if (jointName == 'Right Knee') angleOffset = 0;
    if (jointName == 'Left Knee') angleOffset = math.pi;
    
    // Draw the arrow at a distance from the joint
    final Offset arrowPosition = Offset(
      center.dx + 30 * math.cos(angleOffset),
      center.dy + 30 * math.sin(angleOffset)
    );
    
    final Path arrowPath = Path();
    arrowPath.moveTo(arrowPosition.dx, arrowPosition.dy);
    arrowPath.lineTo(arrowPosition.dx - 10 * math.cos(angleOffset - math.pi/6), 
                     arrowPosition.dy - 10 * math.sin(angleOffset - math.pi/6));
    arrowPath.lineTo(arrowPosition.dx - 10 * math.cos(angleOffset + math.pi/6), 
                     arrowPosition.dy - 10 * math.sin(angleOffset + math.pi/6));
    arrowPath.close();
    
    canvas.drawPath(arrowPath, arrowPaint);
  }
  
  void _drawMannequinLines(Canvas canvas, Size size, Paint paint) {
    // Find joint positions by name
    Offset getJointPosition(String name) {
      final joint = joints.firstWhere(
        (j) => j.name == name,
        orElse: () => Joint(name, const Offset(0, 0)),
      );
      return Offset(joint.position.dx * size.width, joint.position.dy * size.height);
    }
    
    // Head and neck
    final Offset head = getJointPosition('Head');
    final Offset neck = getJointPosition('Neck');
    
    // Draw head - simplified oval shape
    final Rect headRect = Rect.fromCenter(
      center: head,
      width: size.width * 0.07,
      height: size.height * 0.06,
    );
    canvas.drawOval(headRect, paint);
    
    // Draw face features (simplified)
    final double eyeLevel = head.dy - size.height * 0.005;
    final double eyeDistance = size.width * 0.015;
    
    // Eyes
    canvas.drawLine(
      Offset(head.dx - eyeDistance, eyeLevel),
      Offset(head.dx - eyeDistance + 2, eyeLevel),
      paint
    );
    canvas.drawLine(
      Offset(head.dx + eyeDistance, eyeLevel),
      Offset(head.dx + eyeDistance - 2, eyeLevel),
      paint
    );
    
    // Mouth
    canvas.drawLine(
      Offset(head.dx - size.width * 0.01, head.dy + size.height * 0.01),
      Offset(head.dx + size.width * 0.01, head.dy + size.height * 0.01),
      paint
    );
    
    // Connect head to neck
    canvas.drawLine(head, neck, paint);
    
    // Shoulders
    final Offset rightShoulder = getJointPosition('Right Shoulder');
    final Offset leftShoulder = getJointPosition('Left Shoulder');
    
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
    
    // Hands
    final Offset rightHand = getJointPosition('Right Hand');
    final Offset leftHand = getJointPosition('Left Hand');
    
    // Connect wrists to hands
    canvas.drawLine(rightWrist, rightHand, paint);
    canvas.drawLine(leftWrist, leftHand, paint);
    
    // Draw fingers
    _drawFingers(canvas, size, rightHand, true, paint);
    _drawFingers(canvas, size, leftHand, false, paint);
    
    // Torso
    final Offset rightHip = getJointPosition('Right Hip');
    final Offset leftHip = getJointPosition('Left Hip');
    
    // Draw torso outline
    canvas.drawLine(rightShoulder, rightHip, paint);
    canvas.drawLine(leftShoulder, leftHip, paint);
    canvas.drawLine(rightHip, leftHip, paint);
    
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
    
    // Draw feet
    _drawFoot(canvas, size, rightAnkle, true, paint);
    _drawFoot(canvas, size, leftAnkle, false, paint);
  }
  
  void _drawFingers(Canvas canvas, Size size, Offset hand, bool isRight, Paint paint) {
    const double handWidth = 20.0;
    const double fingerLength = 15.0;
    
    for (int i = 0; i < 4; i++) {
      double offset = (i - 1.5) * handWidth/4;
      
      // Find finger joint positions from our joints list
      String fingerName = isRight ? 
          'Right Finger$i' : 'Left Finger$i';
      
      Joint? fingerJoint = joints.where((j) => j.name == fingerName).isEmpty ? 
          null : joints.firstWhere((j) => j.name == fingerName);
      
      if (fingerJoint != null) {
        Offset fingerPos = Offset(
          fingerJoint.position.dx * size.width,
          fingerJoint.position.dy * size.height
        );
        
        // Draw line from hand to finger joint
        canvas.drawLine(hand, fingerPos, paint);
      }
    }
  }
  
  void _drawFoot(Canvas canvas, Size size, Offset ankle, bool isRight, Paint paint) {
    const double footLength = 25.0;
    final double footDirection = isRight ? 0 : 0;
    
    final Offset footEnd = Offset(
      ankle.dx + footLength * math.cos(footDirection),
      ankle.dy + footLength * math.sin(footDirection)
    );
    
    canvas.drawLine(ankle, footEnd, paint);
  }
  
  @override
  bool shouldRepaint(SimplifiedMannequinPainter oldDelegate) {
    return oldDelegate.selectedJoint != selectedJoint;
  }
}