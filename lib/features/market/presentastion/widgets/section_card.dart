import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final String emoji;
  final Widget child;
  
  const SectionCard({
    required this.title,
    required this.emoji,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF0D1527)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: const Border.fromBorderSide(
            BorderSide(color: Color(0xFF1A2440)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$emoji  $title',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.white70,
                    letterSpacing: .6,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
