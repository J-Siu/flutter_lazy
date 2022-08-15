Simple [log] with global [enableLog] to turn on and off and [forced] to override individually. Part of [lazy] collection.

## Features


Name|Api Stable|Description
---|---|---
[log]|yes|Simple log

## Getting started

```sh
flutter pub add lazy_log
```

## Usage

[Working progress, examples will be added]

Import with `as lazy` as follow:

```dart
import 'package:lazy_log/lazy_log.dart' as lazy;

main(){
  lazy.enableLog = false;
  /// Override with [force]
  lazy.log('This is a test', forced: true);
}
```
