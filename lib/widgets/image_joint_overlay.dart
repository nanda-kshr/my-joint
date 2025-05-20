import 'package:flutter/material.dart';
import '../models/joint.dart';
import '../painters/simplified_mannequin_painter.dart';

class ImageJointOverlay extends StatefulWidget {
  final String imagePath;
  final List<Joint> joints;
  final String? selectedJoint;
  final bool showJointDots;
  final bool showAlignmentTools;
  final Function(String) onJointSelected;
  final Function(int, Offset) onJointMoved;
  
  const ImageJointOverlay({
    super.key,
    required this.imagePath,
    required this.joints,
    this.selectedJoint,
    required this.showJointDots,
    required this.showAlignmentTools,
    required this.onJointSelected,
    required this.onJointMoved,
  });
  
  @override
  State<ImageJointOverlay> createState() => _ImageJointOverlayState();
}

class _ImageJointOverlayState extends State<ImageJointOverlay> {
  // Image size information for precise positioning
  final GlobalKey _imageKey = GlobalKey();
  Size? _imageSize;
  Offset? _imagePosition;
  
  @override
  void initState() {
    super.initState();
    // Add a post-frame callback to get the image size after it's rendered
    WidgetsBinding.instance.addPostFrameCallback((_) => _getImageSize());
  }
  
  // Gets the actual image dimensions on screen
  void _getImageSize() {
    final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _imageSize = renderBox.size;
        _imagePosition = renderBox.localToGlobal(Offset.zero);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the optimal container size to maintain aspect ratio
        // Adjust this aspect ratio to match your human body image
        const double imageAspectRatio = 0.5; // Change this to match your image's width/height ratio
        
        double containerWidth;
        double containerHeight;
        
        if (constraints.maxWidth / constraints.maxHeight > imageAspectRatio) {
          // Screen is wider than image aspect ratio
          containerHeight = constraints.maxHeight;
          containerWidth = containerHeight * imageAspectRatio;
        } else {
          // Screen is taller than image aspect ratio
          containerWidth = constraints.maxWidth;
          containerHeight = containerWidth / imageAspectRatio;
        }
        
        return Center(
          child: SizedBox(
            width: containerWidth,
            height: containerHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // The background image
                Image.asset(
                  widget.imagePath,
                  key: _imageKey,
                  fit: BoxFit.contain,
                ),
                
                // The joints overlay
                if (widget.showJointDots && !widget.showAlignmentTools)
                  GestureDetector(
                    onTapDown: (TapDownDetails details) {
                      final RenderBox box = context.findRenderObject() as RenderBox;
                      final Offset localPosition = box.globalToLocal(details.globalPosition);
                      
                      // Find nearest joint
                      Joint? nearestJoint;
                      double minDistance = double.infinity;
                      
                      for (final joint in widget.joints) {
                        final Offset jointPixelPosition = Offset(
                          joint.position.dx * box.size.width,
                          joint.position.dy * box.size.height,
                        );
                        
                        final double distance = (jointPixelPosition - localPosition).distance;
                        final double threshold = joint.isFingerOrToe ? 15.0 : 25.0;
                        
                        if (distance < minDistance && distance < threshold) {
                          minDistance = distance;
                          nearestJoint = joint;
                        }
                      }
                      
                      if (nearestJoint != null) {
                        widget.onJointSelected(nearestJoint.name);
                      }
                    },
                    child: CustomPaint(
                      painter: SimplifiedMannequinPainter(
                        joints: widget.joints,
                        selectedJoint: widget.selectedJoint,
                        drawJointsOnly: true,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                  
                // Alignment tools
                if (widget.showAlignmentTools)
                  Stack(
                    children: List.generate(
                      widget.joints.length,
                      (index) {
                        final joint = widget.joints[index];
                        return Positioned(
                          left: joint.position.dx * containerWidth - 12,
                          top: joint.position.dy * containerHeight - 12,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              final RenderBox box = context.findRenderObject() as RenderBox;
                              final Offset localPosition = box.globalToLocal(details.globalPosition);
                              
                              // Calculate normalized position within our constrained container
                              double dx = (localPosition.dx) / containerWidth;
                              double dy = (localPosition.dy) / containerHeight;
                              
                              // Clamp to valid range
                              dx = dx.clamp(0.0, 1.0);
                              dy = dy.clamp(0.0, 1.0);
                              
                              widget.onJointMoved(index, Offset(dx, dy));
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.5),
                                border: Border.all(color: Colors.blue, width: 2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}