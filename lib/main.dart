import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/employee_view_model.dart';
import 'views/employee_list_screen.dart';
import 'views/helpers/feedback_helper.dart';

void main() {
  runApp(const MainApp());
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EmployeeViewModel()
            ..onCrudResult = (result) {
              final state = scaffoldMessengerKey.currentState;
              if (state != null) {
                FeedbackHelper.showCrudSnackBar(state, result);
              }
            },
        ),
      ],
      child: MaterialApp(
        title: 'Employee App',
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
          ),
        ),
        home: const EmployeeListScreen(),
      ),
    );
  }
}
