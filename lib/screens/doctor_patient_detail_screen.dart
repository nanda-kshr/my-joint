import 'package:my_joints/screens/patient_disease_scores_screen.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'patient_history_screen.dart';

class DoctorPatientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> patient;
  const DoctorPatientDetailScreen({super.key, required this.patient});

  @override
  State<DoctorPatientDetailScreen> createState() => _DoctorPatientDetailScreenState();
}

class _DoctorPatientDetailScreenState extends State<DoctorPatientDetailScreen> {
  late ApiService _apiService;
  late int _uid;

  @override
  void initState() {
    super.initState();
    _uid = widget.patient['uid'] is int
        ? widget.patient['uid']
        : int.tryParse(widget.patient['uid'].toString()) ?? 0;
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiService = ApiService(prefs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.patient['name'] ?? 'Patient Details',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            if (widget.patient['email'] != null)
              Text(
                widget.patient['email'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient info card
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade600,
                    Colors.blue.shade700,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.patient['name'] ?? 'Unknown Patient',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.patient['email'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        if (widget.patient['age'] != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Age: ${widget.patient['age']}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (widget.patient['sex'] != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.patient['sex'],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Medical Records',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comprehensive health data overview',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9,
              children: [
                _buildDataCard(
                  context,
                  title: 'Complaints',
                  color: Colors.blue,
                  fetcher: () => _apiService.getPatientComplaints(uid: _uid),
                  onCreate: () => _showCreateDialog('complaint'),
                  itemBuilder: (item) => ListTile(
                    title: Text(item['complaint'] ?? item['text'] ?? ''),
                    subtitle: item['createdAt'] != null
                        ? Text('Added: ' + (item['createdAt'] ?? ''))
                        : null,
                  ),
                ),
                _buildDataCard(
                  context,
                  title: 'Comorbidities',
                  color: Colors.orange,
                  fetcher: () => _apiService.getPatientComorbidities(uid: _uid),
                  onCreate: () => _showCreateDialog('comorbidity'),
                  itemBuilder: (item) => ListTile(
                    title: Text(item['text'] ?? ''),
                    subtitle: item['createdAt'] != null
                        ? Text('Added: ' + (item['createdAt'] ?? ''))
                        : null,
                  ),
                ),
                _buildDataCard(
                  context,
                  title: 'Disease Scores',
                  color: Colors.green,
                  fetcher: () => _apiService.getPatientDiseaseScores(uid: _uid),
                  onCreate: () => _showCreateDialog('disease_score'),
                  itemBuilder: (item) => ListTile(
                    title: Text('SDAI: ${item['SDAI'] ?? item['sdai'] ?? 'N/A'}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DAS28-CRP: ${item['DAS_28_CRP'] ?? item['das_28_crp'] ?? 'N/A'}'),
                        if (item['createdAt'] != null)
                          Text('Date: ${item['createdAt']}'),
                      ],
                    ),
                  ),
                ),
                _buildDataCard(
                  context,
                  title: 'Medications',
                  color: Colors.purple,
                  fetcher: () => _apiService.getPatientMedications(uid: _uid),
                  onCreate: () => _showCreateDialog('medication'),
                  itemBuilder: (item) {
                    final meds = item['medications'] is List
                        ? item['medications']
                        : [];
                    return ListTile(
                      title: Text(meds.isNotEmpty
                          ? meds.map((m) => m['name']).join(', ')
                          : 'No medications'),
                      subtitle: item['createdAt'] != null
                          ? Text('Added: ' + (item['createdAt'] ?? ''))
                          : null,
                    );
                  },
                ),
                _buildDataCard(
                  context,
                  title: 'Investigations',
                  color: Colors.teal,
                  fetcher: () => _apiService.getPatientInvestigations(uid: _uid),
                  onCreate: () => _showCreateDialog('investigation'),
                  itemBuilder: (item) => ListTile(
                    title: Text('Hb: ${item['Hb'] ?? 'N/A'}'),
                    subtitle: item['createdAt'] != null
                        ? Text('Date: ${item['createdAt']}')
                        : null,
                  ),
                ),
                _buildDataCard(
                  context,
                  title: 'Treatments',
                  color: Colors.indigo,
                  fetcher: () => _apiService.getPatientTreatments(uid: _uid),
                  onCreate: () => _showCreateDialog('treatment'),
                  itemBuilder: (item) => ListTile(
                    title: Text(item['treatment'] ?? ''),
                    subtitle: item['createdAt'] != null
                        ? Text('Started: ' + (item['createdAt'] ?? ''))
                        : null,
                  ),
                ),
                _buildDataCard(
                  context,
                  title: 'Referrals',
                  color: Colors.red,
                  fetcher: () => _apiService.getPatientReferrals(uid: _uid),
                  onCreate: () => _showCreateDialog('referral'),
                  itemBuilder: (item) => ListTile(
                    title: Text(item['text'] ?? ''),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(
    BuildContext context, {
    required String title,
    required Color color,
    required Future<List<dynamic>> Function() fetcher,
    required VoidCallback onCreate,
    required Widget Function(dynamic item) itemBuilder,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _navigateToHistoryScreen(context, title);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with title and create button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title, 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: color,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.8), color],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onCreate,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Content area
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.1),
                              color.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIconForTitle(title),
                          size: 24, 
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'View History', 
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to see all records',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 9,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'complaints':
        return Icons.sick;
      case 'comorbidities':
        return Icons.health_and_safety;
      case 'disease scores':
        return Icons.analytics;
      case 'medications':
        return Icons.medication;
      case 'investigations':
        return Icons.science;
      case 'treatments':
        return Icons.medical_services;
      case 'referrals':
        return Icons.send;
      default:
        return Icons.folder_open;
    }
  }

  void _navigateToHistoryScreen(BuildContext context, String type) {
    if (type.toLowerCase() == 'disease scores') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatientDiseaseScoresScreen(
            patientUid: _uid,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatientHistoryScreen(
            type: type,
            uid: _uid,
          ),
        ),
      );
    }
  }

  void _showCreateDialog(String type) {
    showDialog(
      context: context,
      builder: (context) {
        switch (type) {
          case 'complaint':
            final controller = TextEditingController();
            return AlertDialog(
              title: const Text('Add Complaint'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Complaint'),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;
                    await _apiService.createPatientComplaint(uid: _uid, text: controller.text.trim());
                    if (mounted) setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          case 'comorbidity':
            final controller = TextEditingController();
            return AlertDialog(
              title: const Text('Add Comorbidity'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Comorbidity'),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;
                    await _apiService.createPatientComorbidity(uid: _uid, text: controller.text.trim());
                    if (mounted) setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          case 'disease_score':
            final sdaiController = TextEditingController();
            final dasController = TextEditingController();
            return AlertDialog(
              title: const Text('Add Disease Score'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: sdaiController,
                    decoration: const InputDecoration(labelText: 'SDAI'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: dasController,
                    decoration: const InputDecoration(labelText: 'DAS28-CRP'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final sdai = double.tryParse(sdaiController.text.trim());
                    final das = double.tryParse(dasController.text.trim());
                    if (sdai == null || das == null) return;
                    await _apiService.createPatientDiseaseScore(uid: _uid, sdai: sdai, das28crp: das);
                    if (mounted) setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          case 'medication':
            final List<Map<String, TextEditingController>> meds = [
              {
                'name': TextEditingController(),
                'dose': TextEditingController(),
                'period': TextEditingController(),
              }
            ];
            return StatefulBuilder(
              builder: (context, setStateDialog) => AlertDialog(
                title: const Text('Add Medications'),
                content: SizedBox(
                  width: 350,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...meds.asMap().entries.map((entry) {
                        final i = entry.key;
                        final m = entry.value;
                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: m['name'],
                                decoration: const InputDecoration(labelText: 'Name'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: m['dose'],
                                decoration: const InputDecoration(labelText: 'Dose'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: m['period'],
                                decoration: const InputDecoration(labelText: 'Period'),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: meds.length > 1
                                  ? () {
                                      setStateDialog(() => meds.removeAt(i));
                                    }
                                  : null,
                            ),
                          ],
                        );
                      }),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Row'),
                          onPressed: () {
                            setStateDialog(() => meds.add({
                                  'name': TextEditingController(),
                                  'dose': TextEditingController(),
                                  'period': TextEditingController(),
                                }));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final medList = meds
                          .where((m) => m['name']!.text.trim().isNotEmpty)
                          .map((m) => {
                                'name': m['name']!.text.trim(),
                                'dose': m['dose']!.text.trim(),
                                'period': m['period']!.text.trim(),
                              })
                          .toList();
                      if (medList.isEmpty) return;
                      await _apiService.createPatientMedications(uid: _uid, medications: medList);
                      if (mounted) setState(() {});
                      Navigator.pop(context);
                    },
                    child: const Text('Create'),
                  ),
                ],
              ),
            );
          case 'investigation':
            final fields = [
              {'label': 'Hb', 'key': 'Hb'},
              {'label': 'Total Leukocyte Count', 'key': 'Total_leukocyte_count'},
              {'label': 'Differential Count', 'key': 'Differential_count'},
              {'label': 'Platelet Count', 'key': 'Platelet_count'},
              {'label': 'ESR', 'key': 'ESR'},
              {'label': 'CRP', 'key': 'CRP'},
              {'label': 'LFT Total Bilirubin', 'key': 'Lft_total_bilirubin'},
              {'label': 'LFT Direct Bilirubin', 'key': 'Lft_direct_bilirubin'},
              {'label': 'AST', 'key': 'AST'},
              {'label': 'ALT', 'key': 'ALT'},
              {'label': 'Albumin', 'key': 'Albumin'},
              {'label': 'Total Protein', 'key': 'Total_protein'},
              {'label': 'GGT', 'key': 'GGT'},
              {'label': 'Urea', 'key': 'Urea'},
              {'label': 'Creatinine', 'key': 'creatinine'},
              {'label': 'Uric Acid', 'key': 'uric_acid'},
              {'label': 'Urine Routine', 'key': 'Urine_routine'},
              {'label': 'Urine PCR', 'key': 'Urine_PCR'},
              {'label': 'RA Factor', 'key': 'RA_factor'},
              {'label': 'ANTI CCP', 'key': 'ANTI_CCP'},
            ];
            final controllers = {for (var f in fields) f['key']: TextEditingController()};
            return AlertDialog(
              title: const Text('Add Investigation'),
              content: SizedBox(
                width: 350,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: fields
                        .map((f) => TextField(
                              controller: controllers[f['key']],
                              decoration: InputDecoration(labelText: f['label']),
                            ))
                        .toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final data = <String, dynamic>{'uid': _uid};
                    for (var f in fields) {
                      final val = controllers[f['key']]!.text.trim();
                      if (val.isNotEmpty) data[f['key']!] = val;
                    }
                    await _apiService.createPatientInvestigation(data);
                    if (mounted) setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          case 'treatment':
            final treatmentController = TextEditingController();
            final nameController = TextEditingController();
            final doseController = TextEditingController();
            final routeOptions = ['Tablet', 'Injection', 'Infusion', 'Other'];
            String routeValue = routeOptions[0];
            final freqController = TextEditingController();
            final freqTextController = TextEditingController();
            final timePeriodController = TextEditingController();
            return StatefulBuilder(
              builder: (context, setStateDialog) => AlertDialog(
                title: const Text('Add Treatment'),
                content: SizedBox(
                  width: 350,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: treatmentController,
                          decoration: const InputDecoration(labelText: 'Treatment'),
                        ),
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        TextField(
                          controller: doseController,
                          decoration: const InputDecoration(labelText: 'Dose'),
                        ),
                        DropdownButtonFormField<String>(
                          value: routeValue,
                          items: routeOptions
                              .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                              .toList(),
                          onChanged: (v) => setStateDialog(() => routeValue = v ?? routeValue),
                          decoration: const InputDecoration(labelText: 'Route'),
                        ),
                        TextField(
                          controller: freqController,
                          decoration: const InputDecoration(labelText: 'Frequency (number)'),
                          keyboardType: TextInputType.number,
                        ),
                        TextField(
                          controller: freqTextController,
                          decoration: const InputDecoration(labelText: 'Frequency Text'),
                        ),
                        TextField(
                          controller: timePeriodController,
                          decoration: const InputDecoration(labelText: 'Time Period (weeks)'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _apiService.createPatientTreatment(
                        uid: _uid,
                        treatment: treatmentController.text.trim(),
                        name: nameController.text.trim(),
                        dose: doseController.text.trim(),
                        route: routeValue,
                        frequency: int.tryParse(freqController.text.trim()) ?? 0,
                        frequencyText: freqTextController.text.trim(),
                        timePeriod: int.tryParse(timePeriodController.text.trim()) ?? 0,
                      );
                      if (mounted) setState(() {});
                      Navigator.pop(context);
                    },
                    child: const Text('Create'),
                  ),
                ],
              ),
            );
          case 'referral':
            final controller = TextEditingController();
            return AlertDialog(
              title: const Text('Add Referral'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Referral'),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;
                    await _apiService.createPatientReferral(uid: _uid, text: controller.text.trim());
                    if (mounted) setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
} 