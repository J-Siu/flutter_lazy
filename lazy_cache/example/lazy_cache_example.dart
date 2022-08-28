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
