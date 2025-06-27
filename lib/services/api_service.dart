import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:developer' as developer;

class ApiService {
  static const String baseUrl = 'http://192.168.101.109:3000/api/v1';
  static const String tokenKey = 'auth_token';
  static const String userTypeKey = 'user_type';
  static const String userIdKey = 'user_id';

  final http.Client _client = http.Client();
  final SharedPreferences _prefs;

  ApiService(this._prefs);

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
        Uri.parse('$baseUrl/patient/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      developer.log('Login response status: ${response.statusCode}');
      developer.log('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await setToken(data['token']);
        await _prefs.setString(userTypeKey, 'patient');
        await _prefs.setString(userIdKey, data['patient']['id']);
        developer.log('Patient login successful');
      } else {
        final errorData = jsonDecode(response.body);
        developer.log('Login failed: ${errorData['message']}');
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e, stackTrace) {
      developer.log('Login error: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> patientRegister(Map<String, dynamic> data) async {
    developer.log('Attempting patient registration with data: $data');
    try {
      final url = Uri.parse('$baseUrl/patient/register');
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        await setToken(responseData['token']);
        await _prefs.setString(userTypeKey, 'patient');
        await _prefs.setString(userIdKey, responseData['patient']['id']);
        developer.log('Patient registration successful');
      } else {
        final errorData = jsonDecode(response.body);
        developer.log('Registration failed with status ${response.statusCode}: ${errorData['message']}');
        throw Exception(errorData['message'] ?? 'Registration failed');
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
        Uri.parse('$baseUrl/doctor/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      developer.log('Login response status: ${response.statusCode}');
      developer.log('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await setToken(data['token']);
        await _prefs.setString(userTypeKey, 'doctor');
        await _prefs.setString(userIdKey, data['doctor']['id']);
        developer.log('Doctor login successful');
      } else {
        final errorData = jsonDecode(response.body);
        developer.log('Login failed: ${errorData['message']}');
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e, stackTrace) {
      developer.log('Login error: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> doctorRegister(Map<String, dynamic> data) async {
    developer.log('Attempting doctor registration with data: $data');
    try {
      final url = Uri.parse('$baseUrl/doctor/register');
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        await setToken(responseData['token']);
        await _prefs.setString(userTypeKey, 'doctor');
        await _prefs.setString(userIdKey, responseData['doctor']['id']);
        developer.log('Doctor registration successful');
      } else {
        final errorData = jsonDecode(response.body);
        developer.log('Registration failed with status ${response.statusCode}: ${errorData['message']}');
        throw Exception(errorData['message'] ?? 'Registration failed');
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
  Future<List<dynamic>> getComplaints() async {
    final response = await _request('GET', '/patient/complaints');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load complaints');
    }
  }

  Future<List<dynamic>> getCoMorbidities() async {
    final response = await _request('GET', '/patient/co-morbidities');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load co-morbidities');
    }
  }

  Future<List<dynamic>> getMedications() async {
    final response = await _request('GET', '/patient/medications');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load medications');
    }
  }

  Future<List<dynamic>> getInvestigations() async {
    final response = await _request('GET', '/patient/investigations');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load investigations');
    }
  }

  Future<List<dynamic>> getDiseaseScores() async {
    final response = await _request('GET', '/patient/disease-scores');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load disease scores');
    }
  }

  Future<List<dynamic>> getTreatments() async {
    final response = await _request('GET', '/patient/treatments');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load treatments');
    }
  }

  // Doctor Data
  Future<List<dynamic>> getPatients() async {
    final response = await _request('GET', '/doctor/patients');
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
      '/patient/disease-scores',
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
        Uri.parse('$baseUrl/patient/profile'),
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
        Uri.parse('$baseUrl/doctor/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      developer.log('Profile response status: ${response.statusCode}');
      developer.log('Profile response body: ${response.body}');

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
} 