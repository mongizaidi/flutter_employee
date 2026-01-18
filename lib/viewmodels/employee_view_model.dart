import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/api_service.dart';

/// Result class for CRUD operations
class CrudResult {
  final bool success;
  final String title;
  final String message;
  final VoidCallback? retryAction;

  CrudResult.success(this.title, this.message)
    : success = true,
      retryAction = null;
  CrudResult.error(this.title, this.message, this.retryAction)
    : success = false;
}

class EmployeeViewModel with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Employee> _employees = [];
  bool _isLoading = false;
  String? _loadError; // Only for load/refresh errors

  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get loadError => _loadError;

  // Callback for CRUD operation results (success/error with retry)
  void Function(CrudResult)? onCrudResult;

  Future<void> loadEmployees() async {
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      _employees = await _apiService.fetchEmployees();
    } catch (e) {
      _loadError = e.toString();
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
      final data = {"name": name, "salary": salary, "age": age};

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

      onCrudResult?.call(
        CrudResult.success('Success', 'Employee created successfully'),
      );
    } catch (e) {
      // 6. FAILURE: Rollback - remove the optimistic entry
      _employees.removeWhere((emp) => emp.id == tempId);
      notifyListeners();

      onCrudResult?.call(
        CrudResult.error(
          'Employee creation failed',
          e.toString().replaceFirst('Exception: ', ''),
          () => addEmployee(name, salary, age),
        ),
      );
    }
  }

  Future<void> updateEmployee(
    int id,
    String name,
    String salary,
    String age,
  ) async {
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
      final data = {"name": name, "salary": salary, "age": age};
      await _apiService.updateEmployee(id, data);

      onCrudResult?.call(
        CrudResult.success('Success', 'Employee updated successfully'),
      );
    } catch (e) {
      // 5. FAILURE: Rollback to original
      _employees[index] = backup;
      notifyListeners();

      onCrudResult?.call(
        CrudResult.error(
          'Employee update failed',
          e.toString().replaceFirst('Exception: ', ''),
          () => updateEmployee(id, name, salary, age),
        ),
      );
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

      onCrudResult?.call(
        CrudResult.success('Success', 'Employee deleted successfully'),
      );
    } catch (e) {
      // 4. FAILURE: Rollback - restore the employee
      _employees.insert(index, backup);
      notifyListeners();

      onCrudResult?.call(
        CrudResult.error(
          'Employee deletion failed',
          e.toString().replaceFirst('Exception: ', ''),
          () => deleteEmployee(id),
        ),
      );
    }
  }
}
