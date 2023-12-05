import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prefoods/providers/user_provider.dart';
import 'package:prefoods/styles/theme_colors.dart';

class StyledTextField extends ConsumerWidget {
  const StyledTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      textAlign: TextAlign.center,
      textAlignVertical: TextAlignVertical.center,
      style: backgroundStyle,
      decoration: inputStyle,
      onChanged: (String value) {
        ref.read(userProvider.notifier).setUser(value);
      },
    );
  }
}

TextStyle backgroundStyle = TextStyle(
  color: availableColors["blue"],
  fontSize: 21,
  fontWeight: FontWeight.bold,
);

InputDecoration inputStyle = InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(25.0),
  ),
  filled: true,
  fillColor: availableColors["orange"],
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.pink.shade100,
    ),
  ),
);
