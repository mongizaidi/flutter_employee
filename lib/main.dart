import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/employee_view_model.dart';
import 'views/employee_list_screen.dart';

void main() {
  runApp(const MainApp());
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  void _handleCrudResult(CrudResult result) {
    final state = scaffoldMessengerKey.currentState;
    if (state == null) return;

    state.clearSnackBars();

    if (result.success) {
      state.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(result.message, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      state.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(result.message, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              if (result.retryAction != null)
                TextButton(
                  onPressed: () {
                    state.hideCurrentSnackBar();
                    result.retryAction!();
                  },
                  child: const Text(
                    'RETRY',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () => state.hideCurrentSnackBar(),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(days: 1), // Non-dismissing for error
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EmployeeViewModel()..onCrudResult = _handleCrudResult,
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
