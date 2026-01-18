import 'package:flutter/material.dart';
import 'widgets/error_view.dart';
import 'package:provider/provider.dart';
import '../viewmodels/employee_view_model.dart';
import 'employee_detail_screen.dart';
import 'employee_form_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});
  
  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {

  @override
  void initState() {
    super.initState();
    // Load employees when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmployeeViewModel>(context, listen: false).loadEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<EmployeeViewModel>(context, listen: false).loadEmployees();
            },
          ),
        ],
      ),
      body: Consumer<EmployeeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return ErrorView(message: viewModel.error!, onRetry: viewModel.loadEmployees);
          }

          if (viewModel.employees.isEmpty) {
            return const Center(child: Text('No employees found.'));
          }

          return ListView.separated(
            itemCount: viewModel.employees.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final employee = viewModel.employees[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(employee.employeeName.isNotEmpty 
                      ? employee.employeeName[0] : '?'),
                ),
                title: Text(employee.employeeName),
                subtitle: Text('Age: ${employee.employeeAge}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EmployeeDetailScreen(employee: employee),
                    ),
                  );
                },
              );
            },
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EmployeeFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}