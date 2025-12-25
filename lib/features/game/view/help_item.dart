import 'package:flutter/material.dart';

class HelpItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const HelpItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}
