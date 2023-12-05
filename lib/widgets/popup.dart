import 'package:flutter/material.dart';
import 'package:prefoods/styles/text.dart';
import 'package:prefoods/styles/text_field.dart';

void popup(BuildContext context, String title, bool includesUserInput,
    ButtonStyleButton button) {
  showDialog(
    context: context,
    builder: (contxt) {
      return Dialog(
        child: _popupContent(title, includesUserInput, button),
      );
    },
  );
}

Padding _popupContent(
    String title, bool includesUserInput, ButtonStyleButton button) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: textStyle,
        ),
        if (includesUserInput) const StyledTextField(),
        button,
      ],
    ),
  );
}
