import 'package:flutter/material.dart';

Widget changeBadge(String change, String window, {bool positive = true}) {
  final Color bg = positive ? const Color(0xFF08381F) : const Color(0xFF3A1010);
  final Color fg = positive ? const Color(0xFF46D39A) : const Color(0xFFF87171);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: fg.withOpacity(.35), width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          positive ? Icons.arrow_outward : Icons.south_east,
          size: 16,
          color: fg,
        ),
        const SizedBox(width: 6),
        Text(
          '$change  ',
          style: TextStyle(
            color: fg,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: fg.withOpacity(.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            window,
            style: TextStyle(
              color: fg,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}
