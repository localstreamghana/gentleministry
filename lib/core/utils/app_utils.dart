import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppUtils {
  /// Shows a dialog to confirm exiting the app
  static Future<void> confirmExit(BuildContext context) async {
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Gentle Church?'),
        content: const Text('Are you sure you want to close the app? You will remain logged in.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('EXIT'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }
}