import 'package:flutter/material.dart';

enum AssessmentPhaseType {
  headNeck,
  leftShoulderArm,
  leftHandFingers,
  rightShoulderArm,
  rightHandFingers,
  torsoSpine,
  leftHipLeg,
  leftFootToes,
  rightHipLeg,
  rightFootToes,
  clinicalAssessment,
  summary
}

class AssessmentPhase {
  final AssessmentPhaseType type;
  final String title;
  final String description;
  final List<String> jointNames;
  final double zoomScale;
  final Offset focusPoint; // Normalized coordinates for zoom center
  
  const AssessmentPhase({
    required this.type,
    required this.title,
    required this.description,
    required this.jointNames,
    this.zoomScale = 1.0,
    this.focusPoint = const Offset(0.5, 0.5),
  });
  
  static const List<AssessmentPhase> phases = [
    // 1. Head & Neck
    AssessmentPhase(
      type: AssessmentPhaseType.headNeck,
      title: 'Head & Neck',
      description: 'Select any swollen joints in the head and neck area',
      jointNames: ['Head', 'Neck', 'Jaw'],
      zoomScale: 2.5,
      focusPoint: Offset(0.5, 0.2),
    ),
    
    // 2. Left Shoulder & Arm
    AssessmentPhase(
      type: AssessmentPhaseType.leftShoulderArm,
      title: 'Left Shoulder & Arm',
      description: 'Select any swollen joints in the left shoulder and arm',
      jointNames: [
        'Left Shoulder',
        'Left Collarbone Joint',
        'Left Elbow'
      ],
      zoomScale: 2.2,
      focusPoint: Offset(0.68, 0.32),
    ),
    
    // 3. Left Hand & Fingers
    AssessmentPhase(
      type: AssessmentPhaseType.leftHandFingers,
      title: 'Left Hand & Fingers',
      description: 'Select any swollen joints in the left hand and fingers',
      jointNames: [
        'Left Wrist',
        'Left UFinger0', 'Left UFinger1', 'Left UFinger2', 'Left UFinger3', 'Left UFinger4',
        'Left MFinger0', 'Left MFinger1', 'Left MFinger2', 'Left MFinger3', 'Left MFinger4',
        'Left LFinger0', 'Left LFinger1', 'Left LFinger2', 'Left LFinger3',
      ],
      zoomScale: 3.2,
      focusPoint: Offset(0.85, 0.52),
    ),
    
    // 4. Right Shoulder & Arm
    AssessmentPhase(
      type: AssessmentPhaseType.rightShoulderArm,
      title: 'Right Shoulder & Arm',
      description: 'Select any swollen joints in the right shoulder and arm',
      jointNames: [
        'Right Shoulder',
        'Right Collarbone Joint',
        'Right Elbow'
      ],
      zoomScale: 2.2,
      focusPoint: Offset(0.32, 0.32),
    ),
    
    // 5. Right Hand & Fingers
    AssessmentPhase(
      type: AssessmentPhaseType.rightHandFingers,
      title: 'Right Hand & Fingers',
      description: 'Select any swollen joints in the right hand and fingers',
      jointNames: [
        'Right Wrist',
        'Right UFinger0', 'Right UFinger1', 'Right UFinger2', 'Right UFinger3', 'Right UFinger4',
        'Right MFinger0', 'Right MFinger1', 'Right MFinger2', 'Right MFinger3', 'Right MFinger4',
        'Right LFinger0', 'Right LFinger1', 'Right LFinger2', 'Right LFinger3',
      ],
      zoomScale: 3.2,
      focusPoint: Offset(0.15, 0.52),
    ),
    
    // 6. Torso & Spine
    AssessmentPhase(
      type: AssessmentPhaseType.torsoSpine,
      title: 'Torso & Spine',
      description: 'Select any swollen joints in the central torso area',
      jointNames: [
        'Right Hip', 'Left Hip',
        'Right SI Joint', 'Left SI Joint'
      ],
      zoomScale: 1.8,
      focusPoint: Offset(0.5, 0.47),
    ),
    
    // 7. Left Hip & Leg
    AssessmentPhase(
      type: AssessmentPhaseType.leftHipLeg,
      title: 'Left Hip & Leg',
      description: 'Select any swollen joints in the left hip and leg',
      jointNames: [
        'Left Hip',
        'Left Knee',
        'Left Ankle'
      ],
      zoomScale: 2.2,
      focusPoint: Offset(0.57, 0.6),
    ),
    
    // 8. Left Foot & Toes
    AssessmentPhase(
      type: AssessmentPhaseType.leftFootToes,
      title: 'Left Foot & Toes',
      description: 'Select any swollen joints in the left foot and toes',
      jointNames: [
        'Left UToe0', 'Left UToe1', 'Left UToe2', 'Left UToe3', 'Left UToe4',
        'Left LToe0',
      ],
      zoomScale: 4.0,
      focusPoint: Offset(0.62, 0.84),
    ),
    
    // 9. Right Hip & Leg
    AssessmentPhase(
      type: AssessmentPhaseType.rightHipLeg,
      title: 'Right Hip & Leg',
      description: 'Select any swollen joints in the right hip and leg',
      jointNames: [
        'Right Hip',
        'Right Knee',
        'Right Ankle'
      ],
      zoomScale: 2.2,
      focusPoint: Offset(0.42, 0.6),
    ),
    
    // 10. Right Foot & Toes
    AssessmentPhase(
      type: AssessmentPhaseType.rightFootToes,
      title: 'Right Foot & Toes',
      description: 'Select any swollen joints in the right foot and toes',
      jointNames: [
        'RIGHT UToe0', 'RIGHT UToe1', 'RIGHT UToe2', 'RIGHT UToe3', 'RIGHT UToe4',
        'RIGHT LToe0',
      ],
      zoomScale: 4.0,
      focusPoint: Offset(0.38, 0.84),
    ),
    
    // 11. Clinical Assessment
    AssessmentPhase(
      type: AssessmentPhaseType.clinicalAssessment,
      title: 'Clinical Assessment',
      description: 'Complete the clinical assessment using the sliders below',
      jointNames: [],
      zoomScale: 1.0,
      focusPoint: Offset(0.5, 0.5),
    ),
    
    // 12. Summary
    AssessmentPhase(
      type: AssessmentPhaseType.summary,
      title: 'Assessment Summary',
      description: 'Review your selections and complete the assessment',
      jointNames: [],
      zoomScale: 1.0,
      focusPoint: Offset(0.5, 0.5),
    ),
  ];
}