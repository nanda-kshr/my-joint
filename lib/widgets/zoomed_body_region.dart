import 'package:flutter/material.dart';
import '../models/joint.dart';
import '../models/assessment_phase.dart';
import '../painters/simplified_mannequin_painter.dart';

class ZoomedBodyRegion extends StatefulWidget {
  final List<Joint> joints;
  final Set<String> selectedSwollenJoints;
  final Set<String> selectedTenderJoints;
  final Function(String, bool) onJointTap;
  final double zoomScale;
  final Offset focusPoint;
  
  const ZoomedBodyRegion({
    super.key,
    required this.joints,
    required this.selectedSwollenJoints,
    required this.selectedTenderJoints,
    required this.onJointTap,
    required this.zoomScale,
    required this.focusPoint,
  });
  
  @override
  State<ZoomedBodyRegion> createState() => _ZoomedBodyRegionState();
}

class _ZoomedBodyRegionState extends State<ZoomedBodyRegion> {
  bool isSwollenMode = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mode selector
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Swollen Joints'),
                selected: isSwollenMode,
                onSelected: (selected) {
                  setState(() {
                    isSwollenMode = selected;
                  });
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Tender Joints'),
                selected: !isSwollenMode,
                onSelected: (selected) {
                  setState(() {
                    isSwollenMode = !selected;
                  });
                },
              ),
            ],
          ),
        ),
        
        // Joint selection area
        Expanded(
          child: LayoutBuilder(
      builder: (context, constraints) {
        const double imageAspectRatio = 0.5;
        
        double containerWidth;
        double containerHeight;
        
        if (constraints.maxWidth / constraints.maxHeight > imageAspectRatio) {
          containerHeight = constraints.maxHeight;
          containerWidth = containerHeight * imageAspectRatio;
        } else {
          containerWidth = constraints.maxWidth;
          containerHeight = containerWidth / imageAspectRatio;
        }
        
        // Calculate the zoomed container size
              final double zoomedWidth = containerWidth * widget.zoomScale;
              final double zoomedHeight = containerHeight * widget.zoomScale;
        
        // Calculate offset to center the focus point
        final double offsetX = (containerWidth - zoomedWidth) / 2 + 
                                  (0.5 - widget.focusPoint.dx) * zoomedWidth;
        final double offsetY = (containerHeight - zoomedHeight) / 2 + 
                                  (0.5 - widget.focusPoint.dy) * zoomedHeight;
        
        return Center(
          child: SizedBox(
            width: containerWidth,
            height: containerHeight,
            child: ClipRect(
              child: Stack(
                children: [
                  // Zoomed background image
                  Positioned(
                    left: offsetX,
                    top: offsetY,
                    child: SizedBox(
                      width: zoomedWidth,
                      height: zoomedHeight,
                      child: Image.asset(
                              'assets/images/human_body.jpeg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  
                        // Instructions
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                              'Tap on joints to mark as ${isSwollenMode ? "swollen" : "tender"}.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  
                  // Zoomed joints overlay with gesture detection
                  Positioned(
                    left: offsetX,
                    top: offsetY,
                    child: SizedBox(
                      width: zoomedWidth,
                      height: zoomedHeight,
                      child: GestureDetector(
                        onTapDown: (TapDownDetails details) {
                          // Get the tap position relative to the zoomed image container
                          final Offset tapPosition = details.localPosition;
                          
                          // Convert to normalized coordinates within the original image (0-1)
                          final double normalizedX = tapPosition.dx / zoomedWidth;
                          final double normalizedY = tapPosition.dy / zoomedHeight;
                          
                          // Find the nearest joint
                          Joint? nearestJoint;
                          double minDistance = double.infinity;
                          
                                for (final joint in widget.joints) {
                            // Calculate distance in normalized space
                            final double dx = joint.position.dx - normalizedX;
                            final double dy = joint.position.dy - normalizedY;
                            final double distance = (dx * dx + dy * dy);
                            
                            // Threshold in normalized coordinates (adjusted for zoom)
                            final double baseThreshold = joint.isFingerOrToe ? 0.02 : 0.03;
                                  final double threshold = (baseThreshold / widget.zoomScale) * (baseThreshold / widget.zoomScale);
                            
                            if (distance < minDistance && distance < threshold) {
                              minDistance = distance;
                              nearestJoint = joint;
                            }
                          }
                          
                          if (nearestJoint != null) {
                                  widget.onJointTap(nearestJoint.name, isSwollenMode);
                          }
                        },
                        child: CustomPaint(
                          painter: ZoomedMannequinPainter(
                                  joints: widget.joints,
                                  selectedSwollenJoints: widget.selectedSwollenJoints,
                                  selectedTenderJoints: widget.selectedTenderJoints,
                                  zoomScale: widget.zoomScale,
                          ),
                          size: Size(zoomedWidth, zoomedHeight),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
          ),
        ),
      ],
    );
  }
}

class ZoomedMannequinPainter extends CustomPainter {
  final List<Joint> joints;
  final Set<String> selectedSwollenJoints;
  final Set<String> selectedTenderJoints;
  final double zoomScale;
  
  ZoomedMannequinPainter({
    required this.joints,
    required this.selectedSwollenJoints,
    required this.selectedTenderJoints,
    required this.zoomScale,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint jointPaint = Paint()
      ..color = const Color.fromARGB(255, 100, 150, 200)
      ..style = PaintingStyle.fill;
    
    final Paint jointOutlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final Paint swollenJointPaint = Paint()
      ..color = Colors.red.shade300
      ..style = PaintingStyle.fill;
    
    final Paint swollenJointOutlinePaint = Paint()
      ..color = Colors.red.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final Paint tenderJointPaint = Paint()
      ..color = Colors.orange.shade300
      ..style = PaintingStyle.fill;
    
    final Paint tenderJointOutlinePaint = Paint()
      ..color = Colors.orange.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    // Draw joints
    for (final joint in joints) {
      // Convert normalized joint position to pixel position within the zoomed area
      final Offset position = Offset(
        joint.position.dx * size.width,
        joint.position.dy * size.height,
      );
      
      bool isSwollen = selectedSwollenJoints.contains(joint.name);
      bool isTender = selectedTenderJoints.contains(joint.name);
      
      // Larger joints for better visibility when zoomed
      double radius = joint.isFingerOrToe ? 25.0 : 40.0;
      if (zoomScale > 3.0) {
        radius = joint.isFingerOrToe ? 25.0 : 40.0;
      }
      
      // Draw joint
      if (isSwollen) {
        canvas.drawCircle(position, radius, swollenJointPaint);
        canvas.drawCircle(position, radius, swollenJointOutlinePaint);
      } else if (isTender) {
        canvas.drawCircle(position, radius, tenderJointPaint);
        canvas.drawCircle(position, radius, tenderJointOutlinePaint);
      } else {
        canvas.drawCircle(position, radius, jointPaint);
        canvas.drawCircle(position, radius, jointOutlinePaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(ZoomedMannequinPainter oldDelegate) {
    return oldDelegate.selectedSwollenJoints != selectedSwollenJoints ||
           oldDelegate.selectedTenderJoints != selectedTenderJoints ||
           oldDelegate.zoomScale != zoomScale;
  }
}