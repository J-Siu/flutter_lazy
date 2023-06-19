A collection of flutter UI utilities, widgets, helper functions and handy defaults.

### Features

File|Description
---|---
about.dart|An about pop-up dialog
button_url.dart|Create a button that will open URL on click
download.dart|Trigger browser to save to [filename] with [content]
flutter.dart|Collection of flutter helper functions
html_window_on_close.dart|Setup a callback [action] on browser unload
open_url.dart|Wrapper of 'url_launcher' to auto handle null url
spin_widget.dart|Self contain spinning widget. No need to setup your own animation controller, just pass in [child] and a [ValueNotifier] for start/stop
switch.dart|Classes to build switch easily
text_field.dart|Create text field
theme.dart|Wrapper function to setup a default [ThemeProvider] using `theme_provider`

### Install

```sh
flutter pub add lazy_ui_utils
```

### Usage

```dart
import 'package:lazy_ui_utils/lazy_ui_utils.dart' as lazy;
```

### TODO
- about.dart
  - need better doc
- switch.dart
  - need better doc
  - redesign