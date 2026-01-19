import 'package:hive_flutter/hive_flutter.dart';
import '../models/employee.dart';

class LocalDatabaseService {
  static const String _employeeBoxName = 'employees_box';

  /// Saves the list of employees to the local Hive box
  Future<void> saveEmployees(List<Employee> employees) async {
    final box = Hive.box<Employee>(_employeeBoxName);
    await box.clear();
    await box.addAll(employees);
  }

  /// Retrieves the list of employees from the local Hive box
  List<Employee> getCachedEmployees() {
    final box = Hive.box<Employee>(_employeeBoxName);
    return box.values.toList();
  }

  /// Opens the employee box (should be called during app init)
  static Future<void> init() async {
    await Hive.openBox<Employee>(_employeeBoxName);
  }

  /// Adds a single employee to the local cache
  Future<void> addEmployee(Employee employee) async {
    final box = Hive.box<Employee>(_employeeBoxName);
    await box.add(employee);
  }

  /// Updates a single employee in the local cache by finding their ID
  Future<void> updateEmployee(Employee employee) async {
    final box = Hive.box<Employee>(_employeeBoxName);
    final index = box.values.toList().indexWhere((e) => e.id == employee.id);
    if (index != -1) {
      await box.putAt(index, employee);
    }
  }

  /// Deletes a single employee from the local cache by ID
  Future<void> deleteEmployee(int id) async {
    final box = Hive.box<Employee>(_employeeBoxName);
    final index = box.values.toList().indexWhere((e) => e.id == id);
    if (index != -1) {
      await box.deleteAt(index);
    }
  }

  /// Clears the local cache
  Future<void> clearCache() async {
    final box = Hive.box<Employee>(_employeeBoxName);
    await box.clear();
  }
}
