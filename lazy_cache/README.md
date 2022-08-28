Lazy [Cache] provides an indexed local storage on top of the shared_preferences package.

## Features

- Build in index for all entries
- Each entry is stored individually in local storage
- `clear()` only removes entries under `keyPrefix`

## Getting started

```sh
flutter pub add lazy_cache
```

## Usage

```dart
import 'package:lazy_cache/lazy_cache.dart'
```

## Example

```dart
import 'package:lazy_cache/lazy_cache.dart' as lazy;

void main() async {
  var sampleCache = lazy.Cache(keyPrefix: 'sampleCache');

  for (int i = 0; i < 10; i++) {
    await sampleCache.set(i.toString(), 'Sample data: $i');
  }

  for (int i = 0; i < 10; i++) {
    print(await sampleCache.get(i.toString()));
  }

  print(sampleCache.index);

  sampleCache.clear();
}
```

## Limitation

- Only support `String` data for simplicity.
- `toJson()` and `fromJson` not provided as entries are not kept in memory.

## Additional information

Part of [flutter_lazy](https://github.com/j-siu/flutter_lazy).