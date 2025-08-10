import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientHistoryScreen extends StatefulWidget {
  final String type;
  final int uid;
  const PatientHistoryScreen({super.key, required this.type, required this.uid});

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    await _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      List<dynamic> data;
      switch (widget.type.toLowerCase()) {
        case 'complaints':
          data = await _apiService.getPatientComplaints(uid: widget.uid);
          break;
        case 'comorbidities':
          data = await _apiService.getPatientComorbidities(uid: widget.uid);
          break;
        case 'disease scores':
          data = await _apiService.getPatientDiseaseScores(uid: widget.uid);
          break;
        case 'medications':
          data = await _apiService.getPatientMedications(uid: widget.uid);
          break;
        case 'investigations':
          data = await _apiService.getPatientInvestigations(uid: widget.uid);
          break;
        case 'treatments':
          data = await _apiService.getPatientTreatments(uid: widget.uid);
          break;
        case 'referrals':
          data = await _apiService.getPatientReferrals(uid: widget.uid);
          break;
        default:
          data = [];
      }
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildItem(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildItemContent(item),
      ),
    );
  }

  Widget _buildItemContent(dynamic item) {
    switch (widget.type.toLowerCase()) {
      case 'complaints':
        return _buildComplaintItem(item);
      case 'comorbidities':
        return _buildComorbidityItem(item);
      case 'disease scores':
        return _buildDiseaseScoreItem(item);
      case 'medications':
        return _buildMedicationItem(item);
      case 'investigations':
        return _buildInvestigationItem(item);
      case 'treatments':
        return _buildTreatmentItem(item);
      case 'referrals':
        return _buildReferralItem(item);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildComplaintItem(dynamic item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.sick, color: Colors.blue.shade600, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complaint',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    item['complaint'] ?? item['text'] ?? 'No description',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (item['createdAt'] != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow('Date Added', _formatDate(item['createdAt']), Icons.calendar_today),
        ],
      ],
    );
  }

  Widget _buildComorbidityItem(dynamic item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.health_and_safety, color: Colors.orange.shade600, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comorbidity',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    item['text'] ?? 'No description',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (item['createdAt'] != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow('Date Added', _formatDate(item['createdAt']), Icons.calendar_today),
        ],
      ],
    );
  }

  Widget _buildDiseaseScoreItem(dynamic item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.analytics, color: Colors.green.shade600, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Disease Activity Scores',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildScoreCard(
                'SDAI',
                item['SDAI'] ?? item['sdai'] ?? 'N/A',
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildScoreCard(
                'DAS28-CRP',
                item['DAS_28_CRP'] ?? item['das_28_crp'] ?? 'N/A',
                Colors.green,
              ),
            ),
          ],
        ),
        if (item['createdAt'] != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow('Assessment Date', _formatDate(item['createdAt']), Icons.calendar_today),
        ],
      ],
    );
  }

  Widget _buildMedicationItem(dynamic item) {
    final meds = item['medications'] is List ? item['medications'] : [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.medication, color: Colors.purple.shade600, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Medications',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (meds.isNotEmpty) ...[
          ...meds.map<Widget>((med) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade100),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            med['name'] ?? 'Unknown medication',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          if (med['dose'] != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Dose: ${med['dose']}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (med['period'] != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Period: ${med['period']}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ] else ...[
          Text(
            'No medications recorded',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (item['createdAt'] != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow('Date Added', _formatDate(item['createdAt']), Icons.calendar_today),
        ],
      ],
    );
  }

  Widget _buildInvestigationItem(dynamic item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.biotech, color: Colors.red.shade600, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Laboratory Investigations',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Blood Count Section
        if (item['Hb'] != null || item['Total_leukocyte_count'] != null || item['Platelet_count'] != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Complete Blood Count', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                const SizedBox(height: 8),
                if (item['Hb'] != null)
                  Text('Hemoglobin: ${item['Hb']}'),
                if (item['Total_leukocyte_count'] != null)
                  Text('Total Leukocyte Count: ${item['Total_leukocyte_count']}'),
                if (item['Differential_count'] != null)
                  Text('Differential Count: ${item['Differential_count']}'),
                if (item['Platelet_count'] != null)
                  Text('Platelet Count: ${item['Platelet_count']}'),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        // Inflammatory Markers
        if (item['ESR'] != null || item['CRP'] != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Inflammatory Markers', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                const SizedBox(height: 8),
                if (item['ESR'] != null)
                  Text('ESR: ${item['ESR']}'),
                if (item['CRP'] != null)
                  Text('CRP: ${item['CRP']}'),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        // Liver Function Tests
        if (item['Lft_total_bilirubin'] != null || item['AST'] != null || item['ALT'] != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Liver Function Tests', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                const SizedBox(height: 8),
                if (item['Lft_total_bilirubin'] != null)
                  Text('Total Bilirubin: ${item['Lft_total_bilirubin']}'),
                if (item['Lft_direct_bilirubin'] != null)
                  Text('Direct Bilirubin: ${item['Lft_direct_bilirubin']}'),
                if (item['AST'] != null)
                  Text('AST: ${item['AST']}'),
                if (item['ALT'] != null)
                  Text('ALT: ${item['ALT']}'),
                if (item['Albumin'] != null)
                  Text('Albumin: ${item['Albumin']}'),
                if (item['Total_protein'] != null)
                  Text('Total Protein: ${item['Total_protein']}'),
                if (item['GGT'] != null)
                  Text('GGT: ${item['GGT']}'),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        // Kidney Function Tests
        if (item['Urea'] != null || item['creatinine'] != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kidney Function Tests', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                const SizedBox(height: 8),
                if (item['Urea'] != null)
                  Text('Urea: ${item['Urea']}'),
                if (item['creatinine'] != null)
                  Text('Creatinine: ${item['creatinine']}'),
                if (item['uric_acid'] != null)
                  Text('Uric Acid: ${item['uric_acid']}'),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        // Urine Tests
        if (item['Urine_routine'] != null || item['Urine_PCR'] != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Urine Tests', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow.shade700)),
                const SizedBox(height: 8),
                if (item['Urine_routine'] != null)
                  Text('Urine Routine: ${item['Urine_routine']}'),
                if (item['Urine_PCR'] != null)
                  Text('Urine PCR: ${item['Urine_PCR']}'),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        // Immunological Tests
        if (item['RA_factor'] != null || item['ANTI_CCP'] != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Immunological Tests', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                const SizedBox(height: 8),
                if (item['RA_factor'] != null)
                  Text('RA Factor: ${item['RA_factor']}'),
                if (item['ANTI_CCP'] != null)
                  Text('Anti-CCP: ${item['ANTI_CCP']}'),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        // Metadata
        if (item['id'] != null)
          Text('ID: ${item['id']}', style: TextStyle(color: Colors.grey.shade600)),
        if (item['uid'] != null)
          Text('Patient ID: ${item['uid']}', style: TextStyle(color: Colors.grey.shade600)),
        if (item['createdAt'] != null)
          Text('Date: ${item['createdAt']}', style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildTreatmentItem(dynamic item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.healing, color: Colors.indigo.shade600, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Treatment Details',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.indigo.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item['name'] != null) ...[
                Row(
                  children: [
                    Icon(Icons.medication, color: Colors.indigo.shade600, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      item['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (item['dose'] != null)
                _buildInfoRow('Dose', item['dose']),
              if (item['route'] != null)
                _buildInfoRow('Route', item['route']),
              if (item['frequency'] != null || item['frequency_text'] != null)
                _buildInfoRow('Frequency', '${item['frequency'] ?? ''} ${item['frequency_text'] ?? ''}'),
              if (item['Time_Period'] != null)
                _buildInfoRow('Duration', '${item['Time_Period']} months'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (item['id'] != null)
          Text('ID: ${item['id']}', style: TextStyle(color: Colors.grey.shade600)),
        if (item['uid'] != null)
          Text('Patient ID: ${item['uid']}', style: TextStyle(color: Colors.grey.shade600)),
        if (item['createdAt'] != null)
          Text('Started: ${item['createdAt']}', style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildReferralItem(dynamic item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.assignment_return, color: Colors.red.shade600, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Referral Details',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade100),
          ),
          child: Text(
            item['text'] ?? 'No referral details',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(height: 12),
        if (item['id'] != null)
          Text('ID: ${item['id']}', style: TextStyle(color: Colors.grey.shade600)),
        if (item['uid'] != null)
          Text('Patient ID: ${item['uid']}', style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
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
              '${widget.type} History',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            Text(
              'Patient ID: ${widget.uid}',
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade300,
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showCreateDialog(context),
          tooltip: 'Add New ${widget.type}',
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading data...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade100,
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade600, Colors.blue.shade700],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: _fetchData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Try Again',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _data.isEmpty
                  ? Center(
                      child: Container(
                        margin: const EdgeInsets.all(32),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.history,
                                size: 48,
                                color: Colors.blue.shade400,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No ${widget.type.toLowerCase()} found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start by adding the first ${widget.type.toLowerCase().substring(0, widget.type.length - 1)}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue.shade600, Colors.blue.shade700],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () => _showCreateDialog(context),
                                icon: const Icon(Icons.add, color: Colors.white),
                                label: Text(
                                  'Add First ${widget.type.substring(0, widget.type.length - 1)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchData,
                      color: Colors.blue,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _data.length,
                        itemBuilder: (context, index) {
                          return _buildItem(_data[index]);
                        },
                      ),
                    ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    // This should show different create dialogs based on the type
    // For now, we'll show a simple text input for most types
    switch (widget.type.toLowerCase()) {
      case 'complaints':
      case 'comorbidities':
      case 'referrals':
        _showSimpleTextDialog(context);
        break;
      case 'disease scores':
        _showDiseaseScoreDialog(context);
        break;
      case 'medications':
        _showMedicationDialog(context);
        break;
      case 'investigations':
        _showInvestigationDialog(context);
        break;
      case 'treatments':
        _showTreatmentDialog(context);
        break;
      default:
        _showSimpleTextDialog(context);
    }
  }

  void _showSimpleTextDialog(BuildContext context) {
    final controller = TextEditingController();
    String label = widget.type.substring(0, widget.type.length - 1); // Remove 's' from plural
    if (widget.type.toLowerCase() == 'referrals') label = 'Referral';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
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
              try {
                switch (widget.type.toLowerCase()) {
                  case 'complaints':
                    await _apiService.createPatientComplaint(uid: widget.uid, text: controller.text.trim());
                    break;
                  case 'comorbidities':
                    await _apiService.createPatientComorbidity(uid: widget.uid, text: controller.text.trim());
                    break;
                  case 'referrals':
                    await _apiService.createPatientReferral(uid: widget.uid, text: controller.text.trim());
                    break;
                }
                if (mounted) {
                  Navigator.pop(context);
                  _fetchData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$label added successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add $label: ${e.toString().replaceAll('Exception: ', '')}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDiseaseScoreDialog(BuildContext context) {
    final sdaiController = TextEditingController();
    final das28Controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Disease Score'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sdaiController,
              decoration: const InputDecoration(labelText: 'SDAI Score'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: das28Controller,
              decoration: const InputDecoration(labelText: 'DAS28-CRP Score'),
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
              final das = double.tryParse(das28Controller.text.trim());
              if (sdai == null || das == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid numbers')),
                );
                return;
              }
              try {
                await _apiService.createPatientDiseaseScore(uid: widget.uid, sdai: sdai, das28crp: das);
                if (mounted) {
                  Navigator.pop(context);
                  _fetchData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Disease Score added successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add Disease Score: ${e.toString().replaceAll('Exception: ', '')}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showMedicationDialog(BuildContext context) {
    final List<Map<String, TextEditingController>> meds = [
      {
        'name': TextEditingController(),
        'dose': TextEditingController(),
        'period': TextEditingController(),
      }
    ];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
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
                  return Column(
                    children: [
                      TextField(
                        controller: m['name'],
                        decoration: const InputDecoration(labelText: 'Medication Name'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: m['dose'],
                        decoration: const InputDecoration(labelText: 'Dose'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: m['period'],
                        decoration: const InputDecoration(labelText: 'Period'),
                      ),
                      if (meds.length > 1)
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              setStateDialog(() => meds.removeAt(i));
                            },
                          ),
                        ),
                      if (i < meds.length - 1) const Divider(),
                    ],
                  );
                }),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Another Medication'),
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
                if (medList.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter at least one medication')),
                  );
                  return;
                }
                try {
                  await _apiService.createPatientMedications(uid: widget.uid, medications: medList);
                  if (mounted) {
                    Navigator.pop(context);
                    _fetchData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Medications added successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add medications: ${e.toString().replaceAll('Exception: ', '')}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInvestigationDialog(BuildContext context) {
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
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Investigation'),
        content: SizedBox(
          width: 350,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: fields
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: TextField(
                          controller: controllers[f['key']],
                          decoration: InputDecoration(
                            labelText: f['label'],
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
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
              final data = <String, dynamic>{'uid': widget.uid};
              bool hasData = false;
              for (var f in fields) {
                final val = controllers[f['key']]!.text.trim();
                if (val.isNotEmpty) {
                  data[f['key']!] = val;
                  hasData = true;
                }
              }
              if (!hasData) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter at least one investigation value')),
                );
                return;
              }
              try {
                await _apiService.createPatientInvestigation(data);
                if (mounted) {
                  Navigator.pop(context);
                  _fetchData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Investigation added successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add investigation: ${e.toString().replaceAll('Exception: ', '')}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showTreatmentDialog(BuildContext context) {
    final treatmentController = TextEditingController();
    final nameController = TextEditingController();
    final doseController = TextEditingController();
    final routeOptions = ['Tablet', 'Injection', 'Infusion', 'Other'];
    String routeValue = routeOptions[0];
    final freqController = TextEditingController();
    final freqTextController = TextEditingController();
    final timePeriodController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Add Treatment'),
          content: SizedBox(
            width: 350,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: treatmentController,
                    decoration: const InputDecoration(
                      labelText: 'Treatment Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Medication Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: doseController,
                    decoration: const InputDecoration(
                      labelText: 'Dose',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: routeValue,
                    items: routeOptions
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) => setStateDialog(() => routeValue = v ?? routeValue),
                    decoration: const InputDecoration(
                      labelText: 'Route',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: freqController,
                    decoration: const InputDecoration(
                      labelText: 'Frequency (number)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: freqTextController,
                    decoration: const InputDecoration(
                      labelText: 'Frequency Text (e.g., Daily, Weekly)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: timePeriodController,
                    decoration: const InputDecoration(
                      labelText: 'Time Period (weeks)',
                      border: OutlineInputBorder(),
                    ),
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
                if (treatmentController.text.trim().isEmpty || nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter treatment type and medication name')),
                  );
                  return;
                }
                try {
                  await _apiService.createPatientTreatment(
                    uid: widget.uid,
                    treatment: treatmentController.text.trim(),
                    name: nameController.text.trim(),
                    dose: doseController.text.trim(),
                    route: routeValue,
                    frequency: int.tryParse(freqController.text.trim()) ?? 0,
                    frequencyText: freqTextController.text.trim(),
                    timePeriod: int.tryParse(timePeriodController.text.trim()) ?? 0,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    _fetchData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Treatment added successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add treatment: ${e.toString().replaceAll('Exception: ', '')}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [IconData? icon]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, size: 16, color: Colors.grey.shade600),
            ),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.trim(),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}