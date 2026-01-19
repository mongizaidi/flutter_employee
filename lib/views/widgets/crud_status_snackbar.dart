import 'package:flutter/material.dart';
import '../../viewmodels/employee_view_model.dart';

class CrudStatusSnackBar extends SnackBar {
  final CrudResult result;

  CrudStatusSnackBar({
    super.key,
    required this.result,
    VoidCallback? onClose,
  }) : super(
          backgroundColor: result.success ? Colors.green : Colors.red,
          duration: result.success ? const Duration(seconds: 3) : const Duration(days: 1),
          content: Row(
            children: [
              Icon(
                result.success ? Icons.check_circle : Icons.error_outline,
                color: Colors.white,
              ),
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
                    Text(
                      result.message,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (!result.success) ...[
                if (result.retryAction != null)
                  TextButton(
                    onPressed: () {
                      // Note: ScaffoldMessengerState should handle hiding
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
                  onPressed: onClose,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        );
}
