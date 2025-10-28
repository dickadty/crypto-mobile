import 'package:flutter/material.dart';

Color get _panel => const Color(0xFF121A2B);
Widget iconBtn(BuildContext context, IconData icon, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white70, size: 20),
    ),
  );
}
