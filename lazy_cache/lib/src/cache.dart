import 'dart:async';
import 'dart:convert';
import 'package:lazy_log/lazy_log.dart' as lazy;
import 'package:json_preferences/json_preferences.dart';

/// [Cache] is a 'shared_preferences' wrapper to store and retrieve cache [String] using [keyPrefix].[key] as key format.
///
/// Provide [index] support
class Cache extends JsonPreference {
  // --- Input

  /// [keyPrefix] is part of storage key.
  ///
  /// Storage key format: [keyPrefix].[key]
  final String keyPrefix;

  // Only using [JsonPreference] for [_index] for its delayed save feature
  Cache({
    this.keyPrefix = 'indexedCache',
    saveWaitAgainSeconds = 2,
    saveWaitSeconds = 2,
  }) : super(
          key: keyPrefix,
          saveWaitAgainSeconds: saveWaitAgainSeconds,
          saveWaitSeconds: saveWaitSeconds,
        ) {
    _indexLoad();
  }

  // --- Internal
  final Set<String> _index = <String>{};
  final String _indexKey = '##index##';

  bool debugLog = false;

  Future _indexSave() async {
    String debugPrefix = '$runtimeType._indexSave()';
    lazy.log(debugPrefix, forced: debugLog || lazy.logEnable);
    lazy.log(lazy.jsonPretty(_index), forced: debugLog || lazy.logEnable);
    List<String> indexStr = _index.toList();
    try {
      String encoded = jsonEncode(indexStr);
      obj[_indexKey] = encoded;
      // Using [JsonPreference] save()
      super.save();
    } catch (e) {
      lazy.log('$debugPrefix:catch:$e', forced: debugLog || lazy.logEnable);
    }
  }

  Future _indexLoad() async {
    String debugPrefix = '$runtimeType._indexLoad()';
    lazy.log(debugPrefix, forced: debugLog || lazy.logEnable);
    // Using [JsonPreference] load()
    await super.load();
    String encoded = obj[_indexKey] ?? '';
    lazy.log('$debugPrefix:encoded:$encoded',
        forced: debugLog || lazy.logEnable);
    try {
      if (encoded.isNotEmpty) {
        for (String key in jsonDecode(encoded)) {
          _index.add(key);
        }
        lazy.log('$debugPrefix:$_index', forced: debugLog || lazy.logEnable);
      }
    } catch (e) {
      lazy.log('$debugPrefix:catch:$e', forced: debugLog || lazy.logEnable);
    }
  }

  Future _indexAdd(String key) async {
    String debugPrefix = '$runtimeType._indexAdd()';
    lazy.log(debugPrefix, forced: debugLog || lazy.logEnable);
    _index.add(key);
    _indexSave();
  }

  Future _indexRemove(String key) async {
    String debugPrefix = '$runtimeType._indexRemove()';
    lazy.log(debugPrefix, forced: debugLog || lazy.logEnable);
    _index.remove(key);
    if (_index.isEmpty) {
      // Don't save, remove the index entry from local storage
      var pref = await getPref();
      // obj[Index] is saved under [keyPrefix] entry
      pref.remove(keyPrefix);
    } else {
      _indexSave();
    }
  }

  String _key(String key) {
    assert('$keyPrefix.$key' != _indexKey, "Do not use '##index##' as key.");
    return '$keyPrefix.$key';
  }

  /// Return index as [List<String>]
  List<String> get index => _index.toList();

  /// Remove all entries with [keyPrefix] from local storage
  Future clear() async {
    for (String key in _index) {
      remove(key);
    }
  }

  /// Get entry with [key] from local storage
  Future<String> get(String key) async {
    String debugPrefix = '$runtimeType.get()';
    lazy.log(debugPrefix, forced: debugLog || lazy.logEnable);
    var pref = await getPref();
    return pref.getString(_key(key)) ?? '';
  }

  /// Remove entry with [key] from local storage
  Future remove(String key) async {
    String debugPrefix = '$runtimeType.remove()';
    lazy.log(debugPrefix, forced: debugLog || lazy.logEnable);
    var pref = await getPref();
    _indexRemove(key);
    pref.remove(_key(key));
  }

  /// Add/Set entry with [key] = [data] in local storage
  Future set(String key, String data) async {
    String debugPrefix = '$runtimeType.set()';
    lazy.log(debugPrefix, forced: debugLog || lazy.logEnable);
    var pref = await getPref();
    _indexAdd(key);
    pref.setString(_key(key), data);
  }
}
