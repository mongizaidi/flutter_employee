import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/employee.dart';

class ApiService {
  static String baseUrl = 'https://dummy.restapiexample.com/api/v1';

  /// Converts HTTP status codes to user-friendly error messages
  String _getErrorMessage(int statusCode, {String? context}) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Unauthorized. Please log in again.';
      case 403:
        return 'Access denied. You don\'t have permission.';
      case 404:
        return context != null ? '$context not found.' : 'Resource not found.';
      case 408:
        return 'Request timed out. Please try again.';
      case 429:
        return 'Too many requests. Please wait a moment.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return 'Request failed. Please try again.';
        } else if (statusCode >= 500) {
          return 'Server error. Please try again later.';
        }
        return 'Something went wrong (Error $statusCode).';
    }
  }

  /// Handles common exceptions and returns user-friendly messages
  String _handleException(Object e) {
    if (e is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (e is HttpException) {
      return 'Could not connect to server.';
    } else if (e is FormatException) {
      return 'Invalid response from server.';
    } else if (e.toString().contains('Connection refused')) {
      return 'Server is not running. Please start the mock server.';
    }
    return e.toString().replaceFirst('Exception: ', '');
  }

  // GET: all employees
  Future<List<Employee>> fetchEmployees() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/employees'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['status'] == 'success') {
          final List<dynamic> data = body['data'];
          return data.map((json) => Employee.fromJson(json)).toList();
        } else {
          throw Exception(body['message'] ?? 'Failed to load employees');
        }
      } else {
        throw Exception(_getErrorMessage(response.statusCode, context: 'Employees'));
      }
    } catch (e) {
      throw Exception(_handleException(e));
    }
  }

  // GET: employee by ID
  Future<Employee> fetchEmployee(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/employee/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['status'] == 'success' && body['data'] != null) {
          return Employee.fromJson(body['data']);
        } else {
          throw Exception('Employee details not available');
        }
      } else {
        throw Exception(_getErrorMessage(response.statusCode, context: 'Employee'));
      }
    } catch (e) {
      throw Exception(_handleException(e));
    }
  }

  // POST: create new employee
  Future<int> createEmployee(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'success') {
          return body['data']['id'] ?? DateTime.now().millisecondsSinceEpoch;
        }
        throw Exception(body['message'] ?? 'Failed to create employee');
      } else {
        throw Exception(_getErrorMessage(response.statusCode, context: 'Create employee'));
      }
    } catch (e) {
      throw Exception(_handleException(e));
    }
  }
  
  // PUT: update existing employee by ID
  Future<void> updateEmployee(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update/$id'),
        body: json.encode(data),
      );

      if (response.statusCode != 200) {
        throw Exception(_getErrorMessage(response.statusCode, context: 'Update employee'));
      }
    } catch (e) {
      throw Exception(_handleException(e));
    }
  }

  // DELETE: delete employee by ID
  Future<void> deleteEmployee(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/delete/$id'));

      if (response.statusCode != 200) {
        throw Exception(_getErrorMessage(response.statusCode, context: 'Delete employee'));
      }
    } catch (e) {
      throw Exception(_handleException(e));
    }
  }
}
