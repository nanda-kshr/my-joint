
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:developer' as developer;

Future<List<dynamic>> getAllDoctors(ApiService api) async {
  final response = await api._client.get(Uri.parse('${ApiService.baseUrl}/doctor/patient.php'));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to fetch doctors');
  }
}

// Request consultation
Future<void> requestConsultation(ApiService api, {required String patientId, required String doctorId, required String message}) async {
  final headers = await api._authHeaders();
  final response = await api._client.post(
    Uri.parse('${ApiService.baseUrl}/doctor/consult-request.php'),
    headers: headers,
    body: jsonEncode({
      'patient_id': patientId,
      'doctor_id': doctorId,
      'message': message,
    }),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to send consultation request');
  }
}

class ApiService {
  // Pain Assessment APIs
  Future<void> savePainAssessment({required String patientId, required int painScore}) async {
    final response = await _request('POST', '/patient/pain-assessment.php', body: {
      'patient_id': patientId,
      'pain_score': painScore,
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to save pain assessment');
    }
  }

  Future<List<dynamic>> getPainAssessments({required String patientId}) async {
    final response = await _request('GET', '/patient/pain-assessment.php?patient_id=$patientId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['scores'] ?? [];
    } else {
      throw Exception('Failed to fetch pain assessments');
    }
  }
  // static const String baseUrl = 'http://localhost:3000/api';
  static const String baseUrl = 'http://10.190.79.103/api';
  static const String tokenKey = 'auth_token';
  static const String userTypeKey = 'user_type';
  static const String userIdKey = '_id';

  final http.Client _client = http.Client();
  final SharedPreferences _prefs;

  ApiService(this._prefs);

  // Public authenticated GET request
  Future<http.Response> getAuthenticated(String url) async {
    return await _client.get(
      Uri.parse(url),
      headers: await _authHeaders(),
    );
  }

  // Update notification status (accept/reject)
  Future<http.Response> updateNotificationStatus(String notificationId, String status) async {
    final url = Uri.parse('$baseUrl/doctor/notifications/update.php');
    final headers = await _authHeaders();
    return await _client.put(
      url,
      headers: headers,
      body: jsonEncode({
        'id': notificationId,
        'status': status
      }),
    );
  }

    // Health Records APIs
  Future<List<dynamic>> getPatientFiles({required String patientId}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/patient/files.php?patient_id=$patientId'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['files'] ?? [];
    } else {
      throw Exception('Failed to fetch patient files');
    }
  }

  Future<String> uploadPatientFile({required String patientId, required String filePath, required String fileName}) async {
    if (kIsWeb) {
      throw Exception('File upload is not supported on web.');
    }
    final uri = Uri.parse('$baseUrl/patient/upload.php');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(await _authHeaders(multipart: true));
    request.fields['patient_id'] = patientId.toString();
    request.files.add(await http.MultipartFile.fromPath('file', filePath, filename: fileName));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['filename'] ?? '';
    } else {
      throw Exception('Failed to upload file');
    }
  }

  Future<http.Response> downloadPatientFile({required String storedFilename}) async {
    final uri = Uri.parse('$baseUrl/patient/download.php?filename=$storedFilename');
    final response = await _client.get(uri, headers: await _authHeaders());
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to download file');
    }
  }

  Future<Map<String, String>> _authHeaders({bool multipart = false}) async {
    final token = await getToken();
    return {
      if (!multipart) 'Content-Type': 'application/json',
      if (multipart) 'Content-Type': 'multipart/form-data',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Token Management
  Future<String?> getToken() async {
    return _prefs.getString(tokenKey);
  }

  Future<void> setToken(String token) async {
    await _prefs.setString(tokenKey, token);
  }

  Future<void> clearToken() async {
    await _prefs.remove(tokenKey);
  }

  Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null) return false;
    return !JwtDecoder.isExpired(token);
  }

  // Store user type
  Future<void> setUserType(String type) async {
    await _prefs.setString(userTypeKey, type);
  }

  // Get user type
  Future<String?> getUserType() async {
    return _prefs.getString(userTypeKey);
  }

  // Clear stored data
  Future<void> clearStoredData() async {
    await clearToken();
    await _prefs.remove(userTypeKey);
    await _prefs.remove(userIdKey);
  }

  // Generic request method with authentication
  Future<http.Response> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final token = await getToken();
    final defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final url = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = {...defaultHeaders, ...?headers};

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(url, headers: requestHeaders);
      case 'POST':
        return await http.post(
          url,
          headers: requestHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'PUT':
        return await http.put(
          url,
          headers: requestHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'DELETE':
        return await http.delete(url, headers: requestHeaders);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  // Patient Authentication
  Future<void> patientLogin(String email, String password) async {
    developer.log('Attempting patient login for email: $email');
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/signin.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': 'patient',
        }),
      );

      developer.log('Login response status: ${response.statusCode}');
      developer.log('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await setToken(data['token']);
        await _prefs.setString(userTypeKey, 'patient');
        await _prefs.setString(userIdKey, data['user']['id'].toString());
        developer.log('Patient login successful');
      } else {
        final errorData = jsonDecode(response.body);
        developer.log('Login failed: ${errorData['error']}');
        throw Exception(errorData['error'] ?? 'Login failed');
      }
    } catch (e, stackTrace) {
      developer.log('Login error: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> patientRegister(Map<String, dynamic> data) async {
    developer.log('Attempting patient registration with data: $data');
    try {
      final url = Uri.parse('$baseUrl/patient/signup.php');
      developer.log('Making POST request to: $url');
      
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode(data);
      developer.log('Request headers: $headers');
      developer.log('Request body: $body');

      final response = await _client.post(
        url,
        headers: headers,
        body: body,
      );

      developer.log('Response status code: ${response.statusCode}');
      developer.log('Response headers: ${response.headers}');
      developer.log('Response body: ${response.body}');

      if (response.statusCode == 201) {
        // Registration successful, but no token returned
        // User needs to login after registration
        developer.log('Patient registration successful');
      } else {
        final errorData = jsonDecode(response.body);
        developer.log('Registration failed with status ${response.statusCode}: ${errorData['error']}');
        throw Exception(errorData['error'] ?? 'Registration failed');
      }
    } catch (e, stackTrace) {
      developer.log('Registration error: $e', error: e, stackTrace: stackTrace);
      if (e is http.ClientException) {
        developer.log('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  // Doctor Authentication
  Future<void> doctorLogin(String email, String password) async {
    developer.log('Attempting doctor login for email: $email');
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/signin.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': 'doctor',
        }),
      );

      developer.log('Login response status: ${response.statusCode}');
      developer.log('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await setToken(data['token']);
        await _prefs.setString(userTypeKey, 'doctor');
        await _prefs.setString(userIdKey, data['user']['id'].toString());
        developer.log('Doctor login successful');
      } else {
        final errorData = jsonDecode(response.body);
        developer.log('Login failed: ${errorData['error']}');
        throw Exception(errorData['error'] ?? 'Login failed');
      }
    } catch (e, stackTrace) {
      developer.log('Login error: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> doctorRegister(Map<String, dynamic> data) async {
    developer.log('Attempting doctor registration with data: $data');
    try {
      final url = Uri.parse('$baseUrl/doctor/signup.php');
      developer.log('Making POST request to: $url');
      
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode(data);
      developer.log('Request headers: $headers');
      developer.log('Request body: $body');

      final response = await _client.post(
        url,
        headers: headers,
        body: body,
      );

      developer.log('Response status code: ${response.statusCode}');
      developer.log('Response headers: ${response.headers}');
      developer.log('Response body: ${response.body}');

      if (response.statusCode == 201) {
        // Registration successful, but no token returned
        // User needs to login after registration
        developer.log('Doctor registration successful');
      } else {
        final errorData = jsonDecode(response.body);
        developer.log('Registration failed with status ${response.statusCode}: ${errorData['error']}');
        throw Exception(errorData['error'] ?? 'Registration failed');
      }
    } catch (e, stackTrace) {
      developer.log('Registration error: $e', error: e, stackTrace: stackTrace);
      if (e is http.ClientException) {
        developer.log('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  // Patient Data
  Future<List<dynamic>> getPatientComplaints({String? uid}) async {
    final id = uid ?? await getUserId();
    if (id == null) throw Exception('No patient UID');
    final response = await _request('GET', '/patient/complaints.php?uid=$id');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load complaints');
    }
  }

  Future<void> addPatientComplaint({required String? uid, required String text}) async {
    if (uid == null) throw Exception('No patient UID');
    final response = await _request('POST', '/patient/complaints.php', body: {
      'uid': uid,
      'text': text,
    });
    if (response.statusCode != 201) {
      throw Exception('Failed to add complaint');
    }
  }

  Future<void> deletePatientComplaint({required int id}) async {
    final response = await _request('DELETE', '/patient/complaints.php', body: {'id': id});
    if (response.statusCode != 200) {
      throw Exception('Failed to delete complaint');
    }
  }

  Future<List<dynamic>> getPatientReferrals({String? uid}) async {
    final id = uid ?? await getUserId();
    if (id == null) throw Exception('No patient UID');
    final response = await _request('GET', '/patient/referrals.php?uid=$id');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load referrals');
    }
  }

  Future<void> addPatientReferral({required String? uid, required String text}) async {
    if (uid == null) throw Exception('No patient UID');
    final response = await _request('POST', '/patient/referrals.php', body: {
      'uid': uid,
      'text': text,
    });
    if (response.statusCode != 201) {
      throw Exception('Failed to add referral');
    }
  }

  // Doctor Data
  Future<List<dynamic>> getPatients() async {
    final response = await _request('GET', '/doctor/patient.php');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load patients');
    }
  }

  Future<List<dynamic>> getTimeSlots() async {
    final response = await _request('GET', '/doctor/time-slots');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load time slots');
    }
  }

  Future<List<dynamic>> getConsultations() async {
    final response = await _request('GET', '/doctor/consultations');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load consultations');
    }
  }

  // Save Disease Score
  Future<Map<String, dynamic>> saveDiseaseScore(Map<String, dynamic> scoreData) async {
    final response = await _request(
      'POST',
      '/patient/disease_score.php',
      body: scoreData,
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to save disease score');
    }
  }

  // Patient Profile
  Future<Map<String, dynamic>> getPatientProfile() async {
    developer.log('Fetching patient profile');
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        Uri.parse('$baseUrl/patient/profile.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      developer.log('Profile response status: ${response.statusCode}');
      developer.log('Profile response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        return data['patient'];
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch profile');
      }
    } catch (e, stackTrace) {
      developer.log('Error fetching profile: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Doctor Profile
  Future<Map<String, dynamic>> getDoctorProfile() async {
    developer.log('Fetching doctor profile');
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        Uri.parse('$baseUrl/doctor/profile.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['doctor'];
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch profile');
      }
    } catch (e, stackTrace) {
      developer.log('Error fetching profile: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<String?> getUserId() async {
    return _prefs.getString(userIdKey);
  }

  Future<List<dynamic>> getPatientComorbidities({String? uid}) async {
    final id = uid ?? await getUserId();
    if (id == null) throw Exception('No patient UID');
    final response = await _request('GET', '/patient/comorbidities.php?uid=$id');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load comorbidities');
    }
  }

  Future<void> addPatientComorbidity({required String? uid, required String text}) async {
    if (uid == null) throw Exception('No patient UID');
    final response = await _request('POST', '/patient/comorbidities.php', body: {
      'uid': uid,
      'text': text,
    });
    if (response.statusCode != 201) {
      throw Exception('Failed to add comorbidity');
    }
  }

  Future<void> deletePatientComorbidity({required int id}) async {
    final response = await _request('DELETE', '/patient/comorbidities.php', body: {'id': id});
    if (response.statusCode != 200) {
      throw Exception('Failed to delete comorbidity');
    }
  }

  Future<List<dynamic>> getPatientDiseaseScores({String? uid}) async {
    final id = uid ?? await getUserId();
    if (id == null) throw Exception('No patient UID');
    final response = await _request('GET', '/patient/disease_score.php?uid=$id');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load disease scores');
    }
  }

  Future<void> addPatientDiseaseScore({required String? uid, required double sdai, required double das28crp}) async {
    if (uid == null) throw Exception('No patient UID');
    final response = await _request('POST', '/patient/disease_score.php', body: {
      'uid': uid,
      'sdai': sdai,
      'das_28_crp': das28crp,
    });
    if (response.statusCode != 201) {
      throw Exception('Failed to add disease score');
    }
  }

  Future<void> deletePatientDiseaseScore({required int id}) async {
    final response = await _request('DELETE', '/patient/disease_score.php', body: {'id': id});
    if (response.statusCode != 200) {
      throw Exception('Failed to delete disease score');
    }
  }

  Future<List<dynamic>> getPatientMedications({String? uid}) async {
    final id = uid ?? await getUserId();
    if (id == null) throw Exception('No patient UID');
    final response = await _request('GET', '/patient/medications.php?uid=$id');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load medications');
    }
  }

  Future<void> addPatientMedication({required String? uid, required String medications}) async {
    if (uid == null) throw Exception('No patient UID');
    final response = await _request('POST', '/patient/medications.php', body: {
      'uid': uid,
      'medications': medications,
    });
    if (response.statusCode != 201) {
      throw Exception('Failed to add medication');
    }
  }

  Future<void> deletePatientMedication({required int id}) async {
    final response = await _request('DELETE', '/patient/medications.php', body: {'id': id});
    if (response.statusCode != 200) {
      throw Exception('Failed to delete medication');
    }
  }

  Future<List<dynamic>> getPatientInvestigations({String? uid}) async {
    final id = uid ?? await getUserId();
    if (id == null) throw Exception('No patient UID');
    final response = await _request('GET', '/patient/investigation.php?uid=$id');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load investigations');
    }
  }

  Future<void> addPatientInvestigation({required String? uid, required Map<String, dynamic> data}) async {
    if (uid == null) throw Exception('No patient UID');
    final body = {'uid': uid, ...data};
    final response = await _request('POST', '/patient/investigation.php', body: body);
    if (response.statusCode != 201) {
      throw Exception('Failed to add investigation');
    }
  }

  Future<void> deletePatientInvestigation({required int id}) async {
    final response = await _request('DELETE', '/patient/investigation.php', body: {'id': id});
    if (response.statusCode != 200) {
      throw Exception('Failed to delete investigation');
    }
  }

  Future<List<dynamic>> getPatientTreatments({String? uid}) async {
    final id = uid ?? await getUserId();
    if (id == null) throw Exception('No patient UID');
    final response = await _request('GET', '/patient/treatments.php?uid=$id');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load treatments');
    }
  }

  Future<void> addPatientTreatment({required String? uid, required Map<String, dynamic> data}) async {
    if (uid == null) throw Exception('No patient UID');
    final body = {'uid': uid, ...data};
    final response = await _request('POST', '/patient/treatments.php', body: body);
    if (response.statusCode != 201) {
      throw Exception('Failed to add treatment');
    }
  }

  Future<void> deletePatientTreatment({required int id}) async {
    final response = await _request('DELETE', '/patient/treatments.php', body: {'id': id});
    if (response.statusCode != 200) {
      throw Exception('Failed to delete treatment');
    }
  }

  Future<void> deletePatientReferral({required int id}) async {
    final response = await _request('DELETE', '/patient/referrals.php', body: {'id': id});
    if (response.statusCode != 200) {
      throw Exception('Failed to delete referral');
    }
  }

  Future<List<dynamic>> getDoctorPatients() async {
    final response = await _request('GET', '/doctor/patient.php');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load doctor patients');
    }
  }

  Future<void> linkDoctorPatient({required String patientEmail, required String did}) async {
    final response = await _request('POST', '/doctor/patient.php', body: {
      'patient_email': patientEmail,
      'did': did,
    });
    if (response.statusCode != 201) {
      throw Exception('Failed to link doctor and patient');
    }
  }

  // --- CREATE WRAPPERS for DoctorPatientDetailScreen ---
  Future<void> createPatientComplaint({required String uid, required String text}) => addPatientComplaint(uid: uid, text: text);
  Future<void> createPatientComorbidity({required String uid, required String text}) => addPatientComorbidity(uid: uid, text: text);
  Future<void> createPatientDiseaseScore({required String uid, required double sdai, required double das28crp}) => addPatientDiseaseScore(uid: uid, sdai: sdai, das28crp: das28crp);
  Future<void> createPatientMedications({required String uid, required List<Map<String, String>> medications}) => addPatientMedication(uid: uid, medications: jsonEncode(medications));
  Future<void> createPatientInvestigation(Map<String, dynamic> data) => addPatientInvestigation(uid: data['uid'], data: data);
  Future<void> createPatientTreatment({required String uid, required String treatment, required String name, required String dose, required String route, required int frequency, required String frequencyText, required int timePeriod}) => addPatientTreatment(uid: uid, data: {
    'treatment': treatment,
    'name': name,
    'dose': dose,
    'route': route,
    'frequency': frequency,
    'frequency_text': frequencyText,
    'Time_Period': timePeriod,
  });
  Future<void> createPatientReferral({required String uid, required String text}) => addPatientReferral(uid: uid, text: text);

  Future<void> sendOtp(String email) async {
    final response = await _request(
      'POST',
      '/auth/forgot-password.php',
      body: {'email': email},
    );
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to send OTP');
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    final response = await _request(
      'POST',
      '/auth/verify-otp.php',
      body: {'email': email, 'otp': otp},
    );
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to verify OTP');
    }
  }

  Future<void> resetPassword(String email, String otp, String password) async {
    final response = await _request(
      'POST',
      '/auth/reset-password.php',
      body: {'email': email, 'otp': otp, 'password': password},
    );
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to reset password');
    }
  }

  Future<String> testAuth() async {
    final response = await _request('GET', '/test-auth');
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to test auth');
    }
  }

  Future<String> testJwt() async {
    final response = await _request('GET', '/test-jwt');
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to test JWT');
    }
  }
}