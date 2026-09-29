
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android Emulator: use 10.0.2.2 to access your computer.
  static const String baseUrl = 'http://10.222.100.147:5000';

  static const Duration timeout = Duration(seconds: 30);

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _post(
      '/register',
      {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _post(
      '/login',
      {
        'email': email,
        'password': password,
      },
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> predict({
    required double studyHours,
    required double sleepHours,
    required double screenTime,
  }) async {
    final response = await _post(
      '/predict',
      {
        'study_hours': studyHours,
        'sleep_hours': sleepHours,
        'screen_time': screenTime,
      },
    );

    return _handleResponse(response);
  }

  static Future<http.Response> _post(
      String endpoint,
      Map<String, dynamic> data,
      ) async {
    try {
      return await http
          .post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      )
          .timeout(timeout);
    } on http.ClientException catch (e) {
      throw Exception('Unable to connect to server: $e');
    } on FormatException {
      throw Exception('Invalid server URL or response format.');
    } on Exception catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  static Map<String, dynamic> _handleResponse(
      http.Response response,
      ) {
    if (response.body.isEmpty) {
      throw Exception(
        'Server returned an empty response '
            '(HTTP ${response.statusCode}).',
      );
    }

    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw Exception(
        'Server returned an invalid response '
            '(HTTP ${response.statusCode}).',
      );
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('Invalid server response format.');
    }

    if (decoded is Map<String, dynamic>) {
      final error =
          decoded['error'] ??
              decoded['message'] ??
              'Server error';

      throw Exception(
        '$error (HTTP ${response.statusCode})',
      );
    }

    throw Exception(
      'Server error (HTTP ${response.statusCode})',
    );
  }
}