import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../viewmodels/employee_view_model.dart';

class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeFormScreen({super.key, this.employee});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _salaryController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.employee?.employeeName ?? '',
    );
    _salaryController = TextEditingController(
      text: widget.employee != null ? widget.employee!.employeeSalary : '',
    );
    _ageController = TextEditingController(
      text: widget.employee != null ? widget.employee!.employeeAge : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _salaryController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<EmployeeViewModel>(context, listen: false);

      if (widget.employee == null) {
        // Create - Optimistic
        viewModel.addEmployee(
          _nameController.text,
          _salaryController.text,
          _ageController.text,
        );
      } else {
        // Update - Optimistic
        viewModel.updateEmployee(
          widget.employee!.id,
          _nameController.text,
          _salaryController.text,
          _ageController.text,
        );
      }

      // Pop immediately for Optimistic UI
      // The Success/Error feedback will be handled by snackbars in the parent screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.employee != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Employee' : 'New Employee')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                    return 'Name can only contain letters and spaces';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(
                  labelText: 'Salary',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a salary';
                  }
                  final salary = int.tryParse(value);
                  if (salary == null) {
                    return 'Please enter a valid number';
                  }
                  if (salary < 1) {
                    return 'Salary must be at least 1';
                  }
                  if (salary > 1000000) {
                    return 'Salary cannot exceed 1,000,000';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an age';
                  }
                  final age = int.tryParse(value);
                  if (age == null) {
                    return 'Please enter a valid number';
                  }
                  if (age < 18) {
                    return 'Employee must be at least 18 years old';
                  }
                  if (age > 100) {
                    return 'Age cannot exceed 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Consumer<EmployeeViewModel>(
                builder: (context, viewModel, child) {
                  return ElevatedButton(
                    onPressed: viewModel.isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: viewModel.isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            isEditing ? 'Update Employee' : 'Create Employee',
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
