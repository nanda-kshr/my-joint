import 'package:flutter/material.dart';
import '../models/joint.dart';
import '../widgets/image_joint_overlay.dart';
import 'dart:math';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Step 1: Tender Joints, Step 2: Swollen Joints, Step 3: Assessments, Step 4: CRP, Step 5: Result
class Das28SdaiFlowScreen extends StatefulWidget {
  final int? patientUid;
  const Das28SdaiFlowScreen({Key? key, this.patientUid}) : super(key: key);

  @override
  State<Das28SdaiFlowScreen> createState() => _Das28SdaiFlowScreenState();
}

class _Das28SdaiFlowScreenState extends State<Das28SdaiFlowScreen> {
  // Place _resultRow at the very top, after fields, before any usage
  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 15, color: Colors.grey.shade800)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _primaryColor)),
        ],
      ),
    );
  }
  // Helper for results row, must be above _buildStep for scope
  // Helper for results row, must be above _buildStep for scope
  // Helper for results row, must be above _buildStep for scope



  ApiService? _apiService;
  int? _uid;

  @override
  void initState() {
    super.initState();
    _initApi();
  }

  Future<void> _initApi() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    setState(() {
      _uid = widget.patientUid;
    });
  }
  int step = 0;
  Set<String> tenderJoints = {};
  Set<String> swollenJoints = {};
  double patientGlobal = 0;
  double evaluatorGlobal = 0;
  String crpText = '';
  double? sdai;
  double? das28crp;

  // Full joints list from mannequin screen
  final List<Joint> allJoints = [
    Joint('Head', const Offset(0.5, 0.15)),
    Joint('Neck', const Offset(0.5, 0.25)),
    Joint('Right Shoulder', const Offset(0.33, 0.28)),
    Joint('Left Shoulder', const Offset(0.65, 0.28)),
    Joint('Right Elbow', const Offset(0.29, 0.37)),
    Joint('Left Elbow', const Offset(0.7, 0.37)),
    Joint('Right Wrist', const Offset(0.23, 0.45)),
    Joint('Left Wrist', const Offset(0.77, 0.45)),
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
    Joint('Right Hip', const Offset(0.43, 0.47)),
    Joint('Left Hip', const Offset(0.56, 0.47)),
    Joint('Right Knee', const Offset(0.42, 0.6)),
    Joint('Left Knee', const Offset(0.57, 0.6)),
    Joint('Right Ankle', const Offset(0.42, 0.7)),
    Joint('Left Ankle', const Offset(0.57, 0.7)),
    Joint('Left UToe0', const Offset(0.685, 0.815), isFingerOrToe: true),
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

  void nextStep() {
    setState(() {
      step++;
    });
  }

  void prevStep() {
    setState(() {
      step--;
    });
  }

  void calculateScores() {
    final int tender = tenderJoints.length;
    final int swollen = swollenJoints.length;
    final double crp = double.tryParse(crpText) ?? 0.0;
    sdai = tender + swollen + patientGlobal + evaluatorGlobal + crp;
    das28crp = 0.56 * sqrt(tender) + 0.28 * sqrt(swollen) + 0.36 * log(crp + 1) + 0.014 * patientGlobal + 0.96;
  }

  Color get _primaryColor => const Color(0xFF1976D2);
  Color get _accentColor => const Color(0xFF43A047);
  Color get _bgColor => const Color(0xFFF7F9FB);
  Color get _cardColor => Colors.white;
  Color get _inactiveColor => Colors.grey.shade300;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        title: const Text('Disease Activity Score', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: prevStep,
                color: Colors.white,
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Card(
                color: _cardColor,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProgressBar(),
                      const SizedBox(height: 18),
                      _buildStep(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final steps = [
      'Tender Joints',
      'Swollen Joints',
      'Assessment',
      'Result',
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length, (i) {
        final isActive = step == i;
        final isDone = step > i;
        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: isActive
                    ? _primaryColor
                    : isDone
                        ? _accentColor
                        : _inactiveColor,
                child: isDone
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              Text(
                steps[i],
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? _primaryColor : Colors.grey.shade600,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStep() {
    switch (step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Step 1: Select Tender Joints', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _primaryColor)),
            const SizedBox(height: 8),
            Text('Selected: ${tenderJoints.length}', style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                // Set a max height for the image box (e.g., 400px), keep aspect ratio
                final double maxImgHeight = 400;
                final double width = constraints.maxWidth;
                final double height = (width / 0.5).clamp(0, maxImgHeight);
                return Center(
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: _bgColor,
                        child: ImageJointOverlay(
                          imagePath: 'assets/images/human_body.jpeg',
                          joints: allJoints,
                          selectedJoints: tenderJoints,
                          showJointDots: true,
                          showAlignmentTools: false,
                          onJointSelected: (name) {
                            setState(() {
                              if (tenderJoints.contains(name)) {
                                tenderJoints.remove(name);
                              } else {
                                tenderJoints.add(name);
                              }
                            });
                          },
                          onJointMoved: (i, o) {},
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: tenderJoints.isNotEmpty ? nextStep : null,
              child: const Text('Next'),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Step 2: Select Swollen Joints', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _primaryColor)),
            const SizedBox(height: 8),
            Text('Selected: ${swollenJoints.length}', style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final double maxImgHeight = 400;
                final double width = constraints.maxWidth;
                final double height = (width / 0.5).clamp(0, maxImgHeight);
                return Center(
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: _bgColor,
                        child: ImageJointOverlay(
                          imagePath: 'assets/images/human_body.jpeg',
                          joints: allJoints,
                          selectedJoints: swollenJoints,
                          showJointDots: true,
                          showAlignmentTools: false,
                          onJointSelected: (name) {
                            setState(() {
                              if (swollenJoints.contains(name)) {
                                swollenJoints.remove(name);
                              } else {
                                swollenJoints.add(name);
                              }
                            });
                          },
                          onJointMoved: (i, o) {},
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: swollenJoints.isNotEmpty ? nextStep : null,
              child: const Text('Next'),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Step 3: Assessment & CRP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _primaryColor)),
            const SizedBox(height: 18),
            Text('Patient Global Assessment', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade800)),
            Slider(
              value: patientGlobal,
              min: 0,
              max: 10,
              divisions: 100,
              label: patientGlobal.toStringAsFixed(1),
              activeColor: _primaryColor,
              inactiveColor: _inactiveColor,
              onChanged: (v) => setState(() => patientGlobal = v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('0', style: TextStyle(fontSize: 12)),
                Text(patientGlobal.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.bold, color: _primaryColor)),
                const Text('10', style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Evaluator Assessment', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade800)),
            Slider(
              value: evaluatorGlobal,
              min: 0,
              max: 10,
              divisions: 100,
              label: evaluatorGlobal.toStringAsFixed(1),
              activeColor: _primaryColor,
              inactiveColor: _inactiveColor,
              onChanged: (v) => setState(() => evaluatorGlobal = v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('0', style: TextStyle(fontSize: 12)),
                Text(evaluatorGlobal.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.bold, color: _primaryColor)),
                const Text('10', style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            Text('CRP (mg/dL)', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade800)),
            const SizedBox(height: 6),
            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'CRP',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                fillColor: _bgColor,
                filled: true,
              ),
              onChanged: (v) => setState(() => crpText = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: (crpText.isNotEmpty && (patientGlobal > 0 || evaluatorGlobal > 0)) && _apiService != null && _uid != null
                  ? () async {
                      calculateScores();
                      print('[DEBUG] Saving disease scores for UID: $_uid');
                      try {
                        await _apiService!.addPatientDiseaseScore(
                          uid: _uid,
                          sdai: sdai ?? 0,
                          das28crp: das28crp ?? 0,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Disease scores saved!'), backgroundColor: Colors.green),
                          );
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to save: ${e.toString()}'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    }
                  : null,
              child: const Text('Calculate & Save'),
            ),
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Results', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: _accentColor)),
            const SizedBox(height: 16),
            _resultRow('Tender Joints', tenderJoints.length.toString()),
            _resultRow('Swollen Joints', swollenJoints.length.toString()),
            _resultRow('Patient Global', patientGlobal.toStringAsFixed(1)),
            _resultRow('Evaluator', evaluatorGlobal.toStringAsFixed(1)),
            _resultRow('CRP', '$crpText mg/dL'),
            const Divider(height: 32),
            _resultRow('SDAI', sdai?.toStringAsFixed(2) ?? '-'),
            _resultRow('DAS28-CRP', das28crp?.toStringAsFixed(2) ?? '-'),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Back to Graph'),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }

  }
}
