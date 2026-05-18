import 'package:flutter/material.dart';
import '../core/l10n/app_localizations.dart';

/// Shows a modal password prompt for opening a protected .icn file.
/// Returns the entered password, or null if the user cancelled.
Future<String?> showPasswordPrompt(
  BuildContext context,
  AppLocalizations l10n,
) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.get('enter_password')),
      content: TextField(
        controller: controller,
        obscureText: true,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l10n.get('password'),
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (v) => Navigator.pop(ctx, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, null),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, controller.text),
          child: Text(l10n.get('open')),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}
