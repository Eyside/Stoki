// lib/utils/snackbar_helper.dart
import 'package:flutter/material.dart';

class SnackBarHelper {
  /// Affiche une snackbar avec un bouton "Annuler"
  static void showUndoSnackBar({
    required BuildContext context,
    required String message,
    required Future<void> Function() onUndo,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: SnackBarAction(
          label: "Annuler",
          onPressed: () async {
            await onUndo();
          },
        ),
      ),
    );
  }
}
