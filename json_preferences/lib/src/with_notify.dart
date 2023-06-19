import 'base.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:lazy_log/lazy_log.dart' as lazy;

/// `JsonPreferences` with notification
/// - Provide [ChangeNotifier] for data update and a [saveNotifier] triggered by [save]
class JsonPreferenceNotify extends JsonPreference with ChangeNotifier {
  // Constructor
  JsonPreferenceNotify({
    required String key,
    String filenamePrefix = '',
    int saveWaitSeconds = 0,
    int saveWaitAgainSeconds = 0,
  }) : super(
          filenamePrefix: filenamePrefix,
          key: key,
          saveWaitAgainSeconds: saveWaitAgainSeconds,
          saveWaitSeconds: saveWaitSeconds,
        );

  final saveNotifier = ValueNotifier<bool>(true);

  /// Apply/Clone from json object
  /// - Trigger [save] unless wrapped in [noSave]
  /// - Override this if using nested type/object and remember to add [notifyListeners]
  @override
  void fromJson(Map<String, dynamic> jsonObj, {bool debug = false}) {
    try {
      super.fromJson(jsonObj, debug: debug);
      notifyListeners();
    } catch (e) {
      lazy.log('$runtimeType.fromJson():catch():$e');
    }
  }

  /// Save preference to local storage
  /// - Automatically update and save [lastSaveTime]
  /// - [debugMsg] : easier to trace caller
  /// - [dateTime] : manually set the save time. Default is `null` and current time is used.
  /// - [noSaveTime] : set to `true` in case you don't want to update the save time. Default is `false`.
  /// - [saveNotify] : If `true`, trigger [saveNotifier] at end of call. Default `true`.
  /// - [saved] : a callback function to be executed when save is finished. DO NOT ADD [saveNotifier] here, it is already done for you.
  /// - Do not override.
  @override
  Future<void> save({
    DateTime? dateTime,
    Function? saved,
    String debugMsg = '',
    bool noSaveTime = false,
    bool saveNotify = true,
  }) async =>
      super.save(
        debugMsg: debugMsg,
        dateTime: dateTime,
        noSaveTime: noSaveTime,
        saved: () {
          if (saved != null) saved();
          _saved(saveNotify);
        },
      );

  void _saved(bool saveNotify) {
    if (saveNotify) saveNotifier.value = !saveNotifier.value;
  }
}
