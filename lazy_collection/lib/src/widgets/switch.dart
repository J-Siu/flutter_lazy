// ignore_for_file: curly_braces_in_flow_control_structures

import '../flutter.dart' as lazy;
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

enum SwitchType {
  onOff,
  toggle,
}

class Switch {
  BuildContext context;
  bool disabled = false;
  double borderRadius;
  double height;
  double margin;
  double padding;
  double toggleSize;
  double width;
  int durationMilliseconds;

  Switch(
    this.context, {
    this.borderRadius = 20,
    this.disabled = false,
    this.durationMilliseconds = 50,
    this.height = 35,
    this.margin = lazy.defaultPadding,
    this.padding = lazy.defaultPadding,
    this.toggleSize = 25,
    this.width = 70,
  });

  Widget? _themedIcon(IconData? iconData) => Icon(
        iconData,
        color: Theme.of(context).backgroundColor,
      );

  Widget toggle({
    IconData? activeIcon,
    IconData? inactiveIcon,
    String? activeText,
    String? inactiveText,
    bool disabled = false,
    bool showOnOff = false,
    required bool value,
    required void Function(bool) onToggle,
  }) =>
      Padding(
        padding: lazy.padAll(margin),
        child: FlutterSwitch(
          activeColor: Theme.of(context).backgroundColor,
          activeIcon: _themedIcon(activeIcon),
          activeText: activeText,
          borderRadius: borderRadius,
          disabled: disabled,
          duration: Duration(milliseconds: durationMilliseconds),
          height: height,
          inactiveColor: Theme.of(context).backgroundColor,
          inactiveIcon: _themedIcon(inactiveIcon),
          inactiveText: inactiveText,
          onToggle: onToggle,
          padding: padding,
          showOnOff: showOnOff,
          toggleSize: toggleSize,
          value: value,
          width: width,
        ),
      );

  Widget onOff({
    String activeText = 'On',
    String inactiveText = 'Off',
    bool disabled = false,
    bool showOnOff = true,
    required bool value,
    required void Function(bool) onToggle,
  }) =>
      Padding(
        padding: lazy.padAll(margin),
        child: FlutterSwitch(
          activeColor: Theme.of(context).backgroundColor,
          activeText: activeText,
          borderRadius: borderRadius,
          disabled: disabled,
          duration: Duration(milliseconds: durationMilliseconds),
          height: height,
          inactiveColor: Theme.of(context).backgroundColor,
          inactiveText: inactiveText,
          onToggle: onToggle,
          padding: padding,
          showOnOff: showOnOff,
          value: value,
          width: width,
          toggleSize: toggleSize,
        ),
      );
}

class LabeledSwitch {
  double padding;
  IconData? activeIcon;
  IconData? inactiveIcon;
  Switch lazySwitch;
  SwitchType type;
  String name;
  String? activeText;
  String? inactiveText;
  bool showOnOff;
  bool disabled = false;
  bool value;
  void Function(bool) onToggle;

  LabeledSwitch({
    required this.name,
    required this.lazySwitch,
    required this.onToggle,
    required this.type,
    required this.value,
    this.activeIcon,
    this.activeText,
    this.disabled = false,
    this.inactiveIcon,
    this.inactiveText,
    this.padding = lazy.defaultPadding,
    this.showOnOff = false,
  });

  Widget get label => Padding(
        padding: lazy.padAll(padding),
        child: Text(name),
      );

  Widget get button {
    switch (type) {
      case SwitchType.onOff:
        return lazySwitch.onOff(
          disabled: disabled,
          onToggle: onToggle,
          showOnOff: showOnOff,
          value: value,
        );
      case SwitchType.toggle:
        return lazySwitch.toggle(
          activeIcon: activeIcon,
          activeText: activeText,
          disabled: disabled,
          inactiveIcon: inactiveIcon,
          inactiveText: inactiveText,
          onToggle: onToggle,
          showOnOff: showOnOff,
          value: value,
        );
    }
  }

  Row get row => Row(children: [label, button]);

  TableRow get tableRow => TableRow(children: [lazy.tableCell(child: label), lazy.tableCell(child: button)]);

  static Widget table({List<LabeledSwitch> switches = const []}) {
    List<TableRow> tableRows = [];
    for (var s in switches) tableRows.add(s.tableRow);
    return lazy.table(children: tableRows);
  }
}
