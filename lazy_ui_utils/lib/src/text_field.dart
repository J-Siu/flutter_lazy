import '../lazy_ui_utils.dart' as lazy;
import 'package:flutter/material.dart';

/// Create text field
Widget? textField(
  BuildContext context, {
  String? text,
}) {
  if (text != null) {
    return lazy.textPadding(
      text,
      style: lazy.textStyleBodyS(context),
      textAlign: TextAlign.center,
    );
  }
  return null;
}
