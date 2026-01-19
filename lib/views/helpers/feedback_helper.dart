import 'package:flutter/material.dart';
import '../../viewmodels/employee_view_model.dart';
import '../widgets/crud_status_snackbar.dart';

class FeedbackHelper {
  /// Shows a styled SnackBar based on the CRUD result
  static void showCrudSnackBar(ScaffoldMessengerState state, CrudResult result) {
    state.clearSnackBars();
    state.showSnackBar(
      CrudStatusSnackBar(
        result: result,
        onClose: () => state.hideCurrentSnackBar(),
      ),
    );
  }
}
