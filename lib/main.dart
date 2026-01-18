import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/employee_view_model.dart';
import 'views/employee_list_screen.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmployeeViewModel()),
      ],
      child: MaterialApp(
        title: 'Employee App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          useMaterial3: true,
        ),
        home: const EmployeeListScreen(),
      ),
    );
  }
}
