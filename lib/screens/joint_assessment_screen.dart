import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/joint.dart';
import '../models/assessment_phase.dart';
import '../widgets/zoomed_body_region.dart';
import '../utils/joint_alignment_utils.dart';
import 'assessment_summary_screen.dart';

class JointAssessmentScreen extends StatefulWidget {
  const JointAssessmentScreen({super.key});

  @override
  State<JointAssessmentScreen> createState() => _JointAssessmentScreenState();
}

class _JointAssessmentScreenState extends State<JointAssessmentScreen> {
  // Current phase in the assessment workflow
  int currentPhaseIndex = 0;
  
  // Sets of selected joints
  Set<String> selectedSwollenJoints = {};
  Set<String> selectedTenderJoints = {};
  
  // SDAI assessment values
  double patientGlobalAssessment = 0;
  double evaluatorGlobalAssessment = 0;
  double cReactiveProtein = 0;
  
  // Image alignment controller (for development/calibration)
  bool showAlignmentTools = false;
  
  // List of available joints with their positions (normalized coordinates)
  final List<Joint> joints = [
    // Head and neck
    Joint('Head', const Offset(0.5, 0.15)),
    Joint('Neck', const Offset(0.5, 0.25)),
    
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
    Joint('Left UFinger0', const Offset(0.885, 0.493), isFingerOrToe: true),
    Joint('Left UFinger1', const Offset(0.864, 0.52), isFingerOrToe: true),
    Joint('Left UFinger2', const Offset(0.835, 0.536), isFingerOrToe: true),
    Joint('Left UFinger3', const Offset(0.795, 0.55), isFingerOrToe: true),
    Joint('Left UFinger4', const Offset(0.72, 0.534), isFingerOrToe: true),

    Joint('Left MFinger0', const Offset(0.93, 0.51), isFingerOrToe: true),
    Joint('Left MFinger1', const Offset(0.905, 0.542), isFingerOrToe: true),
    Joint('Left MFinger2', const Offset(0.87, 0.57), isFingerOrToe: true),
    Joint('Left MFinger3', const Offset(0.82, 0.588), isFingerOrToe: true),
    Joint('Left MFinger4', const Offset(0.73, 0.57), isFingerOrToe: true),

    Joint('Left LFinger0', const Offset(0.96, 0.528), isFingerOrToe: true),
    Joint('Left LFinger1', const Offset(0.943, 0.567), isFingerOrToe: true),
    Joint('Left LFinger2', const Offset(0.91, 0.598), isFingerOrToe: true),
    Joint('Left LFinger3', const Offset(0.85, 0.61), isFingerOrToe: true),

    // Torso
    Joint('Right Hip', const Offset(0.43, 0.47)),
    Joint('Left Hip', const Offset(0.56, 0.47)),
    
    // Legs
    Joint('Right Knee', const Offset(0.42, 0.6)),
    Joint('Left Knee', const Offset(0.57, 0.6)),
    Joint('Right Ankle', const Offset(0.42, 0.7)),
    Joint('Left Ankle', const Offset(0.57, 0.7)),

    // Toes (left foot)
    Joint('Left UToe0', const Offset(0.685, 0.815), isFingerOrToe: true),
    Joint('Left UToe1', const Offset(0.65, 0.83), isFingerOrToe: true),
    Joint('Left UToe2', const Offset(0.62, 0.835), isFingerOrToe: true),
    Joint('Left UToe3', const Offset(0.58, 0.84), isFingerOrToe: true),
    Joint('Left UToe4', const Offset(0.55, 0.84), isFingerOrToe: true),
    Joint('Left LToe0', const Offset(0.56, 0.865), isFingerOrToe: true),

    // Toes (right foot)
    Joint('RIGHT UToe0', const Offset(0.3, 0.82), isFingerOrToe: true),
    Joint('RIGHT UToe1', const Offset(0.33, 0.83), isFingerOrToe: true),
    Joint('RIGHT UToe2', const Offset(0.37, 0.835), isFingerOrToe: true),
    Joint('RIGHT UToe3', const Offset(0.4, 0.84), isFingerOrToe: true),
    Joint('RIGHT UToe4', const Offset(0.43, 0.84), isFingerOrToe: true),
    Joint('RIGHT LToe0', const Offset(0.43, 0.865), isFingerOrToe: true),
  ];

  void _toggleJointSelection(String jointName, bool isSwollen) {
    setState(() {
      if (isSwollen) {
        if (selectedSwollenJoints.contains(jointName)) {
          selectedSwollenJoints.remove(jointName);
        } else {
          selectedSwollenJoints.add(jointName);
        }
      } else {
        if (selectedTenderJoints.contains(jointName)) {
          selectedTenderJoints.remove(jointName);
        } else {
          selectedTenderJoints.add(jointName);
        }
      }
    });
  }

  void _nextPhase() {
    if (currentPhaseIndex < AssessmentPhase.phases.length - 1) {
      setState(() {
        currentPhaseIndex++;
      });
      
      // If we've reached the summary phase, navigate to summary screen
      if (currentPhaseIndex == AssessmentPhase.phases.length - 1) {
        Navigator.pushNamed(
          context,
          '/assessment-summary',
          arguments: {
            'selectedSwollenJoints': selectedSwollenJoints,
            'selectedTenderJoints': selectedTenderJoints,
            'patientGlobalAssessment': patientGlobalAssessment,
            'evaluatorGlobalAssessment': evaluatorGlobalAssessment,
            'cReactiveProtein': cReactiveProtein,
            'allJoints': joints,
          },
        );
      }
    }
  }

  void _previousPhase() {
    if (currentPhaseIndex > 0) {
      setState(() {
        currentPhaseIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPhase = AssessmentPhase.phases[currentPhaseIndex];
    final isLastPhase = currentPhaseIndex == AssessmentPhase.phases.length - 1;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joint Assessment'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Development tools
          if (showAlignmentTools) ...[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                JointAlignmentUtils.exportJointPositions(joints, context);
              },
              tooltip: 'Export Joint Positions',
            ),
            IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: () async {
                final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
                if (clipboard != null && clipboard.text != null) {
                  final importedJoints = JointAlignmentUtils.importJointPositions(clipboard.text!);
                  if (importedJoints != null) {
                    setState(() {
                      for (int i = 0; i < joints.length; i++) {
                        if (i < importedJoints.length) {
                          joints[i] = importedJoints[i];
                        }
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Joint positions imported successfully')),
                    );
                  }
                }
              },
              tooltip: 'Import Joint Positions',
            ),
          ],
          IconButton(
            icon: Icon(showAlignmentTools ? Icons.check : Icons.settings),
            onPressed: () {
              setState(() {
                showAlignmentTools = !showAlignmentTools;
              });
            },
            tooltip: 'Toggle Alignment Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[50],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (currentPhaseIndex + 1) / AssessmentPhase.phases.length,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${currentPhaseIndex + 1}/${AssessmentPhase.phases.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentPhase.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentPhase.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Main content
          Expanded(
            child: currentPhase.type == AssessmentPhaseType.clinicalAssessment
                ? _buildClinicalAssessmentPhase()
                : ZoomedBodyRegion(
                    joints: joints,
                    selectedSwollenJoints: selectedSwollenJoints,
                    selectedTenderJoints: selectedTenderJoints,
                    onJointTap: _toggleJointSelection,
                    zoomScale: currentPhase.zoomScale,
                    focusPoint: currentPhase.focusPoint,
                  ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentPhaseIndex > 0)
                  TextButton(
                    onPressed: _previousPhase,
                    child: const Text('Previous'),
                  )
                else
                  const SizedBox(width: 80),
                if (currentPhaseIndex < AssessmentPhase.phases.length - 1)
                  ElevatedButton(
                    onPressed: _nextPhase,
                    child: const Text('Next'),
                  )
                else
                  const SizedBox(width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalAssessmentPhase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSliderSection(
            'Patient Global Assessment (PGA)',
            'Rate your overall disease activity (0-10)',
            patientGlobalAssessment,
            (value) => setState(() => patientGlobalAssessment = value),
            10,
          ),
          const SizedBox(height: 24),
          _buildSliderSection(
            'Evaluator Global Assessment (EGA)',
            'Rate your overall disease activity (0-10)',
            evaluatorGlobalAssessment,
            (value) => setState(() => evaluatorGlobalAssessment = value),
            10,
          ),
          const SizedBox(height: 24),
          _buildSliderSection(
            'C-Reactive Protein (CRP)',
            'Enter your CRP value (0-10 mg/L)',
            cReactiveProtein,
            (value) => setState(() => cReactiveProtein = value),
            10,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSection(
    String title,
    String description,
    double value,
    ValueChanged<double> onChanged,
    double max,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Slider(
          value: value,
          onChanged: onChanged,
          min: 0,
          max: max,
          divisions: 10,
          label: value.toStringAsFixed(1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0'),
            Text(value.toStringAsFixed(1)),
            Text(max.toString()),
          ],
        ),
      ],
    );
  }
}