import 'base.dart';
import 'package:flutter/material.dart';

// Material/Flutter
const double defaultPadding = 4;
const double defaultRadius = 10;
const double defaultBorderWidth = 1;

BorderRadius borderRadius(double radius) => BorderRadius.all(Radius.circular(radius));

BoxDecoration boxDecoration({
  double radius = defaultRadius,
  double borderWidth = defaultBorderWidth,
  Color color = Colors.red,
}) =>
    BoxDecoration(
      border: Border.all(color: color, width: borderWidth),
      borderRadius: borderRadius(radius),
      color: Colors.transparent,
    );

Table table({
  List<TableRow> children = const [],
  TableBorder? border,
  TableColumnWidth defaultColumnWidth = const IntrinsicColumnWidth(),
}) =>
    Table(
      border: border,
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: children,
    );

TableCell tableCell({
  TableCellVerticalAlignment verticalAlignment = TableCellVerticalAlignment.middle,
  required Widget child,
}) =>
    TableCell(
      verticalAlignment: verticalAlignment,
      child: child,
    );

// Text Style
TextStyle? textStyleBodyL(BuildContext context) => Theme.of(context).textTheme.bodyLarge;
TextStyle? textStyleBodyM(BuildContext context) => Theme.of(context).textTheme.bodyMedium;
TextStyle? textStyleBodyS(BuildContext context) => Theme.of(context).textTheme.bodySmall;
TextStyle? textStyleHeadlineL(BuildContext context) => Theme.of(context).textTheme.headlineLarge;
TextStyle? textStyleHeadlineM(BuildContext context) => Theme.of(context).textTheme.headlineMedium;
TextStyle? textStyleHeadlineS(BuildContext context) => Theme.of(context).textTheme.headlineSmall;

// Text widget with padding
Padding textPadding(
  String data, {
  EdgeInsets padding = const EdgeInsets.all(defaultPadding),
  TextAlign? textAlign,
  TextStyle? style,
}) {
  return Padding(
    padding: padding,
    child: Text(
      data,
      textAlign: textAlign,
      style: style,
    ),
  );
}

EdgeInsets padAll([double? padding]) => EdgeInsets.all(padding ?? defaultPadding);

ButtonStyle buttonStyleRound({
  double padding = defaultPadding,
  double radius = defaultRadius,
}) =>
    ButtonStyle(
      padding: MaterialStateProperty.all<EdgeInsets>(padAll(padding)),
      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: borderRadius(radius))),
    );

Widget outlinedTextButton({
  double margin = defaultPadding,
  double radius = defaultRadius,
  ButtonStyle? style,
  required Widget child,
  required void Function()? onPressed,
}) {
  return Padding(
    padding: padAll(margin),
    child: OutlinedButton(
      onPressed: onPressed,
      style: style ?? buttonStyleRound(radius: radius),
      child: child,
    ),
  );
}

Widget? textField(BuildContext context, {String? text}) {
  if (text != null) {
    return textPadding(
      text,
      style: textStyleBodyS(context),
      textAlign: TextAlign.center,
    );
  }
  return null;
}

Widget? urlButton(BuildContext context, {String? text, String? url}) {
  if (text == null && url == null) return null;
  if (url == null) {
    return textField(context, text: text!);
  } else {
    String label = text ?? url;
    return OutlinedButton(
      onPressed: () => openUrl(url),
      style: buttonStyleRound(),
      child: Text(
        label,
        style: textStyleBodyS(context),
      ),
    );
  }
}
