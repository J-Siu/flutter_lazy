Intended to save time, especially from things that are very repetitive across projects.

Focus
- supply common, acceptable defaults
- shorthands for common, repetitive tasks

## Features

### Section

Name|Api Stable|Description
---|---|---
`HttpClient.dart`|yes| A [http.BaseClient] wrapper class taking [headers] parameter.
`base.dart`|partial|Collection of static functions and constants
`flutter.dart`|no|Collection of static functions and constants for Flutter
`extensions/`|yes|Extensions for `ByteData`, `DateTime`, `List`, `String`, `Uint8List`
`g_apis/`|yes|[GDrive],[GSign],[GSync]
`theme_provider.dart`|yes|A wrapper function to setup a default `ThemeProvider` from 'package:theme_provider/theme_provider.dart'
`widgets/`|partial|`About`,`SpinningWidget` are stable, `Switch`, `LabeledSwitch` still require some work

### g_apis

Name|Api Stable|Description
---|---|---
`GDrive`|yes|A wrapper class for Google DriveApi with following methods: [create], [get], [list], [searchLatest].
`GSignIn`|yes|[GoogleSignIn] wrapper class with a [signInHandler]. Build in listener for account status change, and a [GSignInMsg] notifier [msg]
`GSync`|yes| A bridge between [GDrive], [GSignIn] and local data/content for syncing to and from Google Drive `appData` space.


## Getting started

```sh
flutter pub add lazy
```

## Usage

[Working progress, examples will be added]

To prevent type collision, alway import with `as lazy` as follow:

```dart
import 'package:lazy_collection/lazy_collection.dart' as lazy;
```

## Additional information

This package will slowly split into smaller packages and under [flutter_lazy](https://github.com/j-siu/flutter_lazy) repo.