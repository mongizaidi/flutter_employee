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
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

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
              _refreshIndicatorKey.currentState?.show();
            },
          ),
        ],
      ),
      body: Consumer<EmployeeViewModel>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.employees.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.loadError != null && controller.employees.isEmpty) {
            return ErrorView(
              message: controller.loadError!,
              onRetry: controller.loadEmployees,
            );
          }

          return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: controller.loadEmployees,
            child: controller.employees.isEmpty
                ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: const Center(
                          child: Text('No employees found.'),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    itemCount: controller.employees.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final employee = controller.employees[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: employee.profileImage.isNotEmpty
                              ? NetworkImage(employee.profileImage)
                              : null,
                          child: employee.profileImage.isEmpty
                              ? Text(
                                  employee.employeeName.isNotEmpty
                                      ? employee.employeeName[0]
                                      : '?',
                                )
                              : null,
                        ),
                        title: Text(employee.employeeName),
                        subtitle: Text('Age: ${employee.employeeAge}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      EmployeeDetailScreen(employee: employee),
                            ),
                          );
                        },
                      );
                    },
                  ),
          );
        },
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
