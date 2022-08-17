import 'dart:async';
import 'dart:convert';
import 'package:lazy_collection/lazy_collection.dart' as lazy;
import 'package:lazy_log/lazy_log.dart' as lazy;
import 'package:shared_preferences/shared_preferences.dart';

/// [JsonPreference] - Json object with [SharedPreferences]
class JsonPreference {
  /// [key] for saving preference
  /// - You must set the [key] or it will throw. This is a safety check to prevent different instances overwriting each other save.
  final String key;

  // Constructor
  JsonPreference({
    required this.key,
    this.filenamePrefix = '',
    this.saveWaitSeconds = 0,
    this.saveWaitAgainSeconds = 0,
  });

  // -- Debug Log Options
  /// enable/disable [fromJson] debug log
  var debugLogJson = false;

  /// enable/disable [fromJson] debug log with content
  var debugLogJsonContent = false;

  /// enable/disable [save] debug log
  var debugLogSave = false;

  /// JSON object holding all preferences
  Map<String, dynamic> obj = {};

  // --- SharedPreferences Setup

  /// Filename prefix when generating filename from [keyFilename].
  String filenamePrefix = '';

  /// Generate filename from [key]
  /// - If [filenamePrefix] is not empty, filename = [filenamePrefix].[key].json, else [key].json
  ///
  /// [JsonPreferences] don't use this internally. This is provided as an utility for external use.
  get keyFilename {
    if (filenamePrefix.isEmpty) {
      return '$key.json';
    } else {
      return '$filenamePrefix.$key.json';
    }
  }

  // Save Setup
  /// Number of seconds before actually trying to save
  int saveWaitSeconds = 0;

  /// If save requested came in during wait,
  /// number of seconds to wait again
  int saveWaitAgainSeconds = 0;

  /// Return preference last save time
  /// - [lastSaveTime] == `DateTime(0)` if [save]/[load] was never called
  DateTime get lastSaveTime => _lastSaveTime;

  /// No-save wrapper
  /// - All [save] calls or triggered [save] are disabled
  /// - Do not override
  void noSave(Function function) {
    _noSave++;
    lazy.log('$runtimeType.noSave():Start($_noSave)');
    function();
    lazy.log('$runtimeType.noSave():End($_noSave)');
    _noSave--;
  }

  /// Apply/Clone from json object
  /// - Trigger [save] unless wrapped in [noSave]
  /// - Override this if using nested type/object
  void fromJson(Map<String, dynamic> jsonObj, {bool debug = false}) {
    try {
      // Deep copy to ensure [obj] won't be modified externally afterwards
      obj = jsonDecode(jsonEncode(jsonObj));
      if (debugLogJsonContent) {
        lazy.log('$runtimeType.fromJson():${jsonObj.toString()}',
            forced: debugLogJson || debug);
      } else {
        lazy.log('$runtimeType.fromJson():${jsonObj.toString().length}',
            forced: debugLogJson || debug);
      }
      save(debugMsg: '$runtimeType.fromJson()');
    } catch (e) {
      lazy.log('$runtimeType.fromJson():catch():$e');
    }
  }

  /// Return a deep copy json object
  /// - Do not override
  Map<String, dynamic> toJson() => jsonDecode(jsonEncode(obj));

  /// Return pretty print json
  @override
  String toString() => lazy.jsonPretty(obj);

  /// load preference from local storage
  /// - [load] use [fromJson] with [noSave] wrapper to apply data
  /// - Do not override.
  Future<void> load({bool forced = false}) async {
    String debugPrefix = '$runtimeType.load()';
    // Get Last save time
    bool different = await _loadTime();
    if (different || forced) {
      // Get Preference
      var pref = await _pref;
      String jsonString = pref.getString(key) ?? '{}';
      lazy.log('$debugPrefix:${jsonString.length}(byte)', forced: debugLogSave);
      Map<String, dynamic> json = jsonDecode(jsonString);
      lazy.log('$debugPrefix:json decoded', forced: debugLogSave);
      noSave(() => fromJson(json));
    } else {
      lazy.log('$debugPrefix:not loaded, already up to date',
          forced: debugLogSave);
    }
  }

  /// Save preference to local storage
  /// - Automatically update and save [lastSaveTime]
  /// - [debugMsg] : easier to trace caller
  /// - [dateTime] : manually set the save time. Default is `null` and current time is used.
  /// - [noSaveTime] : set to `true` in case you don't want to update the save time. Default is `false`.
  /// - [saved] : a callback function to be executed when save is finished
  /// - Do not override.
  Future<void> save({
    DateTime? dateTime,
    Function? saved,
    String debugMsg = '',
    bool noSaveTime = false,
  }) async {
    // Set pending flag
    if (_noSave == 0) {
      String debugPrefix = '$debugMsg -> $runtimeType.save()';
      // Set pending
      lazy.log(debugPrefix, forced: debugLogSave);
      _saveWait(
        debugMsg: debugPrefix,
        dateTime: dateTime,
        noSaveTime: noSaveTime,
        saved: saved,
      );
    }
  }

  // --- internal
  final _pref = SharedPreferences.getInstance();
  var _noSave = 0;
  var _saveWaitAgain = false;
  var _saveWaiting = false;

  get _keySaveTime => '$key.SaveTime';
  var _lastSaveTime = lazy.zeroDay;

  Future _saveWait({
    String debugMsg = '',
    DateTime? dateTime,
    int? waitSeconds,
    Function? saved,
    bool noSaveTime = false,
  }) async {
    String debugPrefix = '$debugMsg -> $runtimeType._saveWait()';
    lazy.log(debugPrefix, forced: debugLogSave);
    if (!_saveWaiting) {
      // set waiting
      _saveWaiting = true;
      // Set wait timer
      await Future.delayed(Duration(seconds: waitSeconds ?? saveWaitSeconds));
      // wait done
      _saveWaiting = false;
      if (_saveWaitAgain) {
        // reset waitAgain and start waiting with 'saveWaitAgainSeconds'
        _saveWaitAgain = false;
        _saveWait(
          dateTime: dateTime,
          debugMsg: '$debugPrefix:waitAgain',
          waitSeconds: saveWaitAgainSeconds,
          noSaveTime: noSaveTime,
          saved: saved,
        );
      } else {
        // no more waiting, save
        _saveGo(
          debugMsg: debugPrefix,
          dateTime: dateTime,
          noSaveTime: noSaveTime,
          saved: saved,
        );
      }
    } else {
      // More save came in, set waitAgain
      lazy.log('$debugPrefix:more save', forced: debugLogSave);
      _saveWaitAgain = true;
    }
  }

  Future _saveGo({
    DateTime? dateTime,
    Function? saved,
    String debugMsg = '',
    bool noSaveTime = false,
  }) async {
    String debugPrefix = '$debugMsg -> $runtimeType._saveGo()';
    var pref = await _pref;
    // When saving/adding default for 1st run we don't want to update time
    if (!noSaveTime) await _saveTime(dateTime: dateTime);
    String json = lazy.jsonPretty(this);
    await pref.setString(key, json);
    if (saved != null) saved();
    lazy.log('$debugPrefix:${json.length}(byte):noSaveTime:$noSaveTime',
        forced: debugLogSave);
  }

  /// Load and set _lastSaveTime from local store
  /// - return true if different it is different from current [_lastSaveTime], else false
  Future<bool> _loadTime() async {
    int ms = 0;
    int msCurrent = _lastSaveTime.millisecondsSinceEpoch;
    var pref = await _pref;
    ms = pref.getInt(_keySaveTime) ?? 0;
    // Only update if different
    if (ms != msCurrent) {
      _lastSaveTime = DateTime.fromMillisecondsSinceEpoch(ms).toUtc();
      lazy.log('$runtimeType.loadTime():$lastSaveTime', forced: debugLogSave);
    }
    return (ms != msCurrent);
  }

  /// Set and save _saveTime to local store
  Future _saveTime({DateTime? dateTime}) async {
    if (dateTime != null) {
      // Set _lastSaveTime with supplied value
      _lastSaveTime = dateTime.toUtc();
    } else {
      // Use current time
      _lastSaveTime = DateTime.now().toUtc();
    }
    var pref = await _pref;
    pref.setInt(_keySaveTime, _lastSaveTime.millisecondsSinceEpoch);
    lazy.log('$runtimeType.saveTime():$lastSaveTime', forced: debugLogSave);
  }
}
