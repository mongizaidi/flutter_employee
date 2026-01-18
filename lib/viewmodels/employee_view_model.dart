import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/api_service.dart';

class EmployeeViewModel with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Employee> _employees = [];
  bool _isLoading = false;
  String? _error;

  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadEmployees() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _employees = await _apiService.fetchEmployees();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Employee?> loadEmployeeDetails(int id) async {
    try {
      return await _apiService.fetchEmployee(id);
    } catch (e) {
      debugPrint('Error fetching details: $e');
      return null;
    }
  }

  Future<void> addEmployee(String name, String salary, String age) async {
    // 1. Generate temporary ID (negative to avoid collision with server IDs)
    final tempId = -DateTime.now().millisecondsSinceEpoch;
    
    // 2. Create employee with temp ID
    final newEmployee = Employee(
      id: tempId,
      employeeName: name,
      employeeSalary: salary,
      employeeAge: age,
      profileImage: "",
    );
    
    // 3. OPTIMISTIC: Add to list immediately (user sees it instantly)
    _employees.add(newEmployee);
    notifyListeners();
    
    // 4. Send API request in background
    try {
      final data = {
        "name": name,
        "salary": salary,
        "age": age,
      };
      
      final realId = await _apiService.createEmployee(data);
      
      // 5. SUCCESS: Replace temp ID with real server ID
      final index = _employees.indexWhere((e) => e.id == tempId);
      if (index != -1) {
        _employees[index] = Employee(
          id: realId,
          employeeName: name,
          employeeSalary: salary,
          employeeAge: age,
          profileImage: "",
        );
        notifyListeners();
      }
      
    } catch (e) {
      // 6. FAILURE: Rollback - remove the optimistic entry
      _employees.removeWhere((emp) => emp.id == tempId);
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateEmployee(int id, String name, String salary, String age) async {
    // 1. Save backup for rollback
    final index = _employees.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final backup = _employees[index];
    
    // 2. Create updated employee
    final updated = Employee(
      id: id,
      employeeName: name,
      employeeSalary: salary,
      employeeAge: age,
      profileImage: backup.profileImage,
    );
    
    // 3. OPTIMISTIC: Update immediately
    _employees[index] = updated;
    notifyListeners();
    
    // 4. Send API request in background
    try {
      final data = {
        "name": name,
        "salary": salary,
        "age": age,
      };
      await _apiService.updateEmployee(id, data);
      // Success - keep the update
      
    } catch (e) {
      // 5. FAILURE: Rollback to original
      _employees[index] = backup;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteEmployee(int id) async {
    // 1. Save backup for rollback
    final index = _employees.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final backup = _employees[index];
    
    // 2. OPTIMISTIC: Remove immediately
    _employees.removeAt(index);
    notifyListeners();
    
    // 3. Send API request in background
    try {
      await _apiService.deleteEmployee(id);
      // Success - employee stays deleted
      
    } catch (e) {
      // 4. FAILURE: Rollback - restore the employee
      _employees.insert(index, backup);
      _error = e.toString();
      notifyListeners();
    }
  }
}
