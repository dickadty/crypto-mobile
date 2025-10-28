import 'package:flutter/material.dart';

Widget priceWidget(double price) {
  return Text(
    price > 0 ? '\$${price.toStringAsFixed(2)}' : '--',
    style: const TextStyle(
      color: Colors.white,
      fontSize: 44,
      fontWeight: FontWeight.w800,
    ),
  );
}
