A simple Google Drive Api wrapper for `googleapis/drive/v3`. Package mainly design for [AppData] scope operation.

## Features

Name|Api Stable|Description
---|---|---
[GDrive]|yes|Simple Google Drive class implementing [create], [get], [list], [searchLatest]
[GDriveStringExt]|yes|Provide an easy way to convert `String` to DriveApi media stream.
[gDriveFileMeta]|yes|A helper function to fill in Drive API `FileMeta`


## Getting started

```sh
flutter pub add lazy_g_drive
```

## Usage

[GDrive] don't have custom constructor. A Google OAuth access token must be set before using any methods.

Import with `as lazy` as follow:

```dart
import 'package:lazy_g_drive/lazy_g_drive.dart' as lazy;

main(){
  var gdrive = lazy.GDrive();
  gdrive.token = 'Google Access Token';

  // ...

}
```
