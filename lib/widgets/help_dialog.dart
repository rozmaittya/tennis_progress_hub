import 'package:flutter/material.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('How this app works'),
      content: const Text(
        '• Add tennis skills you want to improve.\n\n'
        '• Choose 1–3 skills as goals for training or a match.\n\n'
        '• Mark skills as mastered when they feel automatic.',
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'))
      ],
    );
  }
}
