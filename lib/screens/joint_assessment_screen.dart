import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/joint.dart';
import '../widgets/image_joint_overlay.dart';
import '../utils/joint_alignment_utils.dart';
import 'joint_detail_screen.dart';

class JointAssessmentScreen extends StatefulWidget {
  const JointAssessmentScreen({super.key});

  @override
  State<JointAssessmentScreen> createState() => _JointAssessmentScreenState();
}

class _JointAssessmentScreenState extends State<JointAssessmentScreen> {
  // Currently selected joint
  String? selectedJoint;
  
  // Image alignment controller
  bool showAlignmentTools = false;
  bool showJointDots = true;
  
  // List of available joints with their positions (normalized coordinates)
  final List<Joint> joints = [
     // Head and neck
    Joint('Head', const Offset(0.49, 0.15)),
    Joint('Neck', const Offset(0.49, 0.25)),
    
    // Upper body - shoulders
    Joint('Right Shoulder', const Offset(0.33, 0.28)),
    Joint('Left Shoulder', const Offset(0.65, 0.28)),
    
    // Arms
    Joint('Right Elbow', const Offset(0.29, 0.37)),
    Joint('Left Elbow', const Offset(0.7, 0.37)),
    Joint('Right Wrist', const Offset(0.23, 0.45)),
    Joint('Left Wrist', const Offset(0.77, 0.45)),
    

    // Fingers (right hand)
    Joint('Right UFinger0', const Offset(0.096, 0.493), isFingerOrToe: true),
    Joint('Right UFinger1', const Offset(0.12, 0.52), isFingerOrToe: true),
    Joint('Right UFinger2', const Offset(0.15, 0.536), isFingerOrToe: true),
    Joint('Right UFinger3', const Offset(0.19, 0.55), isFingerOrToe: true),
    Joint('Right UFinger4', const Offset(0.27, 0.534), isFingerOrToe: true),

    Joint('Right MFinger0', const Offset(0.056, 0.51), isFingerOrToe: true),
    Joint('Right MFinger1', const Offset(0.08, 0.545), isFingerOrToe: true),
    Joint('Right MFinger2', const Offset(0.11, 0.574), isFingerOrToe: true),
    Joint('Right MFinger3', const Offset(0.16, 0.588), isFingerOrToe: true),
    Joint('Right MFinger4', const Offset(0.26, 0.57), isFingerOrToe: true),

    Joint('Right LFinger0', const Offset(0.03, 0.528), isFingerOrToe: true),
    Joint('Right LFinger1', const Offset(0.047, 0.57), isFingerOrToe: true),
    Joint('Right LFinger2', const Offset(0.08, 0.6), isFingerOrToe: true),
    Joint('Right LFinger3', const Offset(0.14, 0.61), isFingerOrToe: true),

    
    // Fingers (left hand)
    Joint('Left UFinger0', const Offset(0.884, 0.493), isFingerOrToe: true),
    Joint('Left UFinger1', const Offset(0.86, 0.52), isFingerOrToe: true),
    Joint('Left UFinger2', const Offset(0.84, 0.536), isFingerOrToe: true),
    Joint('Left UFinger3', const Offset(0.80, 0.55), isFingerOrToe: true),
    Joint('Left UFinger4', const Offset(0.72, 0.534), isFingerOrToe: true),

    Joint('Left MFinger0', const Offset(0.934, 0.51), isFingerOrToe: true),
    Joint('Left MFinger1', const Offset(0.91, 0.545), isFingerOrToe: true),
    Joint('Left MFinger2', const Offset(0.88, 0.574), isFingerOrToe: true),
    Joint('Left MFinger3', const Offset(0.83, 0.588), isFingerOrToe: true),
    Joint('Left MFinger4', const Offset(0.73, 0.57), isFingerOrToe: true),

    Joint('Left LFinger0', const Offset(0.96, 0.528), isFingerOrToe: true),
    Joint('Left LFinger1', const Offset(0.943, 0.57), isFingerOrToe: true),
    Joint('Left LFinger2', const Offset(0.91, 0.6), isFingerOrToe: true),
    Joint('Left LFinger3', const Offset(0.85, 0.61), isFingerOrToe: true),

    
    // Torso
    Joint('Right Hip', const Offset(0.43, 0.47)),
    Joint('Left Hip', const Offset(0.56, 0.47)),
    
    // Legs
    Joint('Right Knee', const Offset(0.42, 0.6)),
    Joint('Left Knee', const Offset(0.57, 0.6)),
    Joint('Right Ankle', const Offset(0.42, 0.7)),
    Joint('Left Ankle', const Offset(0.57, 0.7)),

    Joint('Left UToe0', const Offset(0.69, 0.82), isFingerOrToe: true),
    Joint('Left UToe1', const Offset(0.65, 0.83), isFingerOrToe: true),
    Joint('Left UToe2', const Offset(0.62, 0.835), isFingerOrToe: true),
    Joint('Left UToe3', const Offset(0.58, 0.84), isFingerOrToe: true),
    Joint('Left UToe4', const Offset(0.55, 0.84), isFingerOrToe: true),

    Joint('Left LToe0', const Offset(0.56, 0.865), isFingerOrToe: true),


    Joint('RIGHT UToe0', const Offset(0.3, 0.82), isFingerOrToe: true),
    Joint('RIGHT UToe1', const Offset(0.33, 0.83), isFingerOrToe: true),
    Joint('RIGHT UToe2', const Offset(0.37, 0.835), isFingerOrToe: true),
    Joint('RIGHT UToe3', const Offset(0.4, 0.84), isFingerOrToe: true),
    Joint('RIGHT UToe4', const Offset(0.43, 0.84), isFingerOrToe: true),

    Joint('RIGHT LToe0', const Offset(0.43, 0.865), isFingerOrToe: true),


  ];

  void _selectJoint(String jointName) {
    setState(() {
      selectedJoint = jointName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joint Assessment Mannequin'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Export button when in alignment mode
          if (showAlignmentTools)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                JointAlignmentUtils.exportJointPositions(joints, context);
              },
              tooltip: 'Export Joint Positions',
            ),
          
          // Import button when in alignment mode
          if (showAlignmentTools)
            IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: () async {
                final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
                if (clipboard != null && clipboard.text != null) {
                  final importedJoints = JointAlignmentUtils.importJointPositions(clipboard.text!);
                  if (importedJoints != null) {
                    setState(() {
                      // Update all joints
                      for (int i = 0; i < joints.length; i++) {
                        if (i < importedJoints.length) {
                          joints[i] = importedJoints[i];
                        }
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Joint positions imported successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid joint position data in clipboard'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              tooltip: 'Import Joint Positions',
            ),
          
          // Add alignment mode toggle
          IconButton(
            icon: Icon(showAlignmentTools ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                showAlignmentTools = !showAlignmentTools;
              });
            },
            tooltip: 'Toggle Alignment Mode',
          ),
          
          // Toggle between showing the joints or not
          IconButton(
            icon: Icon(showJointDots ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                showJointDots = !showJointDots;
              });
            },
            tooltip: 'Toggle Joints Visibility',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Background color
                Container(
                  color: Colors.grey[100],
                ),
                
                // Image and joints overlay
                ImageJointOverlay(
                  imagePath: 'assets/images/human_body.jpeg',
                  joints: joints,
                  selectedJoint: selectedJoint,
                  showJointDots: showJointDots,
                  showAlignmentTools: showAlignmentTools,
                  onJointSelected: _selectJoint,
                  onJointMoved: (index, newPosition) {
                    setState(() {
                      joints[index] = Joint(
                        joints[index].name, 
                        newPosition,
                        isFingerOrToe: joints[index].isFingerOrToe
                      );
                    });
                  },
                ),
                
                // Legend for the checkmark at the left side
                if (!showAlignmentTools)
                  Positioned(
                    left: 20,
                    top: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.touch_app, color: Colors.blue),
                          ),
                          const SizedBox(width: 8),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tap to',
                                style: TextStyle(fontSize: 10),
                              ),
                              Text(
                                'select joints',
                                style: TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                // Alignment instructions
                if (showAlignmentTools)
                  Positioned(
                    left: 20,
                    top: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alignment Mode',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Drag dots to align with body parts',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Tap check icon when done',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Information and assessment panel at the bottom
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[200],
              width: double.infinity,
              child: showAlignmentTools
                ? const Center(
                    child: Text('Alignment mode: positioning joints over image'),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Joint: ${selectedJoint ?? 'None'}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (selectedJoint != null) ...[
                        Text(
                          'You can assess the ${selectedJoint} joint here.',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JointDetailScreen(jointName: selectedJoint!),
                              ),
                            );
                          },
                          child: const Text('Begin Assessment'),
                        ),
                      ] else
                        const Text(
                          'Tap on a joint to select it for assessment.',
                          style: TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}