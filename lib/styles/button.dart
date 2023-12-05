import 'package:flutter/material.dart';
import 'package:prefoods/styles/theme_colors.dart';

ButtonStyleButton button(
    void Function() onPressed, String label, String buttonColorKey) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
      backgroundColor: availableColors[buttonColorKey],
      elevation: 2.5,
      fixedSize: const Size(250, 80),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 2,
          color: availableColors['black']!,
        ),
      ),
    ),
    child: Text(
      label,
      style: const TextStyle(color: Colors.black),
    ),
  );
}
