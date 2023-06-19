import '../lazy_ui_utils.dart' as lazy;
import 'package:flutter/material.dart';

/// Create a button that will open URL on click
Widget? buttonUrl(
  BuildContext context, {
  String? text,
  String? url,
}) {
  if (text == null && url == null) return null;
  if (url == null) {
    return lazy.textField(context, text: text!);
  } else {
    String label = text ?? url;
    return OutlinedButton(
      onPressed: () => lazy.openUrl(url),
      style: lazy.buttonStyleRound(),
      child: Text(
        label,
        style: lazy.textStyleBodyS(context),
      ),
    );
  }
}
