Simple [log] with global [enableLog] to turn on and off and [forced] to override individually.

## Features


Name|Api Stable|Description
---|---|---
[log]|yes|Simple log
[jsonPretty]|yes|Commonly use to print object

## Getting started

```sh
flutter pub add lazy_log
```

## Usage

Import with `as lazy` as follow:

```dart
import 'package:lazy_log/lazy_log.dart' as lazy;

main(){
  lazy.enableLog = false;
  /// Override with [force]
  lazy.log('This is a test', forced: true);
}
```
