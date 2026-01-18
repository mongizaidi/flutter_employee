import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../viewmodels/employee_view_model.dart';
import 'employee_form_screen.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(employee.employeeName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: employee.profileImage.isNotEmpty
                    ? NetworkImage(employee.profileImage)
                    : null,
                child: employee.profileImage.isEmpty
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(Icons.badge, "ID", "${employee.id}"),
            _buildDetailRow(Icons.cake, "Age", employee.employeeAge),
            _buildDetailRow(Icons.attach_money, "Salary", "\$${employee.employeeSalary}"),
            const SizedBox(height: 20),

            Center(
              child: Column(
                children: [
                   ElevatedButton.icon(
                    onPressed: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (_) => EmployeeFormScreen(employee: employee),
                         ),
                       ).then((_) {
                          // Pop back if needed or update logic handling
                          Navigator.pop(context); // Go back to list to see updates
                       });
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Employee"),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Employee'),
                          content: const Text('Are you sure you want to delete this employee?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                         final viewModel = Provider.of<EmployeeViewModel>(context, listen: false);
                         await viewModel.deleteEmployee(employee.id);
                         if (context.mounted) {
                           Navigator.pop(context); // Go back to list
                         }
                      }
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text("Delete Employee", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 16),
          Text(
            "$label:",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
