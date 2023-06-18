import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as gd;
import 'package:lazy_g_drive/lazy_g_drive.dart' as lazy;
import 'package:lazy_log/lazy_log.dart' as lazy;

/// ### Lazy [GSync]
/// - Require Google authorization token with scope 'https://www.googleapis.com/auth/drive.appdata'
/// - Sync content is [String] type
/// - Sync single file content in Google Drive `appData` space
class GSync {
  // --- Internal

  final lazy.GDrive _lazyGDrive = lazy.GDrive();
  DateTime _lastSync = DateTime(0);
  Listenable? _localSaveNotifier;
  String _token = '';
  Timer? _autoTimer;
  bool _auto = false;
  bool _enable = false;

  // --- Output

  /// `true` on [sync] error.
  /// `false` on [sync] success(no error).
  final ValueNotifier<bool> error = ValueNotifier<bool>(false);

  /// `true` when [sync] start
  /// `false` when [sync] stop
  final ValueNotifier<bool> syncing = ValueNotifier<bool>(false);

  // --- Input

  /// Google authorization token with 'https://www.googleapis.com/auth/drive.appdata' scope.
  ///
  /// Pass to Goog Drive API to access 'appdata' space.
  String get token => _token;
  set token(String v) {
    if (_token != v) {
      _token = v;
    }
    if (_token.isNotEmpty) {
      error.value = false;
    }
  }

  /// A callback, should return a filename in [String] to be used remotely
  String Function()? getFilename;

  /// A callback, should return local content in [String] to be saved remotely
  String Function()? getLocalContent;

  /// A callback, should return last local save time
  DateTime Function()? getLocalSaveTime;

  /// A callback, trigger when content is downloaded from remote
  /// - [String] : content of the download
  /// - [DateTime]? : remote last save time. Can be use to set local save time when applying content locally.
  void Function(String, DateTime?)? setLocalContent;

  GSync({
    this.getFilename,
    this.getLocalContent,
    this.getLocalSaveTime,
    this.setLocalContent,
    Listenable? localSaveNotifier,
  }) {
    this.localSaveNotifier = localSaveNotifier;
  }

  /// - true : allow sync all functions
  /// - false(default) : disable sync all functions
  ///
  /// Changing from `false` to `true` will trigger [sync] once
  bool get enable => _enable;
  set enable(bool v) {
    if (_enable != v) {
      _enable = v;
      if (_enable) {
        sync();
      }
    }
  }

  /// Return `DateTime` of last [sync()] successful run.
  DateTime get lastSync => _lastSync;

  /// Return result of [getLocalSaveTime], last save time of content/data saved locally
  ///
  /// Throw if [getLocalSaveTime] not set
  DateTime get localSaveTime {
    String debugPrefix = '$runtimeType:get localSaveTime';
    if (getLocalContent == null) {
      throw ('$debugPrefix:getLocalSaveTime not set');
    }
    return getLocalSaveTime!();
  }

  /// Return result of [getFilename], filename used when saving to Google Drive
  ///
  /// Throw if [getFilename] not set
  String get filename {
    String debugPrefix = '$runtimeType:get filename';
    if (getLocalContent == null) {
      throw ('$debugPrefix:getFilename not set');
    }
    return getFilename!();
  }

  /// Return result of [getLocalContent], content to be saved to Google Drive
  ///
  /// Throw if [getLocalContent] not set
  String get content {
    String debugPrefix = '$runtimeType:get content';
    if (getLocalContent == null) {
      throw ('$debugPrefix:getLocalContent not set');
    }
    return getLocalContent!();
  }

  // --- Options

  /// Auto sync interval
  int autoSyncIntervalMin = 10;

  /// - Trigger [sync] when [v] send notification
  /// - Start listening if not null
  /// - Stop listening if null
  Listenable? get localSaveNotifier => _localSaveNotifier;
  set localSaveNotifier(Listenable? v) {
    if (_localSaveNotifier != v) {
      // 1. Clear current listener
      _localSaveNotifier?.removeListener(() => sync());
      // 2. Update notifier
      _localSaveNotifier = v;
      // 3. Enable new listener
      _localSaveNotifier?.addListener(() => sync());
    }
  }

  /// [auto] control periodic run of [sync] with interval = [autoSyncIntervalMin]
  bool get auto => _auto;
  set auto(bool v) {
    String debugPrefix = '$runtimeType.enableAutoSync($v)';
    lazy.log(debugPrefix);
    if (_auto != v) {
      _auto = v;
      if (v) {
        _autoTimer =
            Timer.periodic(Duration(minutes: autoSyncIntervalMin), (timer) {
          sync();
        });
      } else {
        _autoTimer?.cancel();
      }
    }
  }

  /// - Initiate download from remote if [getLocalSaveTime] < google drive save time
  /// - Initiate upload to remote if [getLocalSaveTime] > google drive save time
  /// - Auto skip or no real action (no throw) if
  ///   - [enable] is `false`, except when [forceDownload] or [forceUpload] is `true`
  ///   - [error].value is `true`, except [ignoreError] set to `true`
  ///   - [forceDownload] and remote file does not exist
  ///   - [syncing].value is `true`, syncing is in progress
  ///   - local(from [getLocalSaveTime]) and remote save time are same
  ///
  /// - [syncing].value : will be set to `true` at beginning and to `false` when done.
  /// - [error].value : will be set to `true` on error. Reset(to `false`) on successful sync.
  ///
  /// - [forceDownload] : when set to `true`, will initiate download from remote regardless of save time on both sides
  /// - [forceUpload] : when set to `true`, will initiate upload to remote regardless of save time on both sides
  ///
  /// - Throw if
  ///   - Both [forceDownload] and [forceUpload] are `true`.
  ///   - [token] is empty.
  Future sync({
    bool forceDownload = false,
    bool forceUpload = false,
    bool ignoreError = false,
  }) async {
    String debugPrefix = '$runtimeType.sync()';

    lazy.log(
        '$debugPrefix:forceDownload=$forceDownload:forceUpload=$forceUpload:ignoreError=$ignoreError');

    if (!enable && !forceDownload && !forceUpload) {
      lazy.log('$debugPrefix:enable=$enable');
      return;
    }
    if (syncing.value) {
      lazy.log('$debugPrefix:syncing already in progress');
      return;
    }
    if (error.value && !ignoreError) {
      lazy.log('$debugPrefix:error=${error.value}');
      return;
    }

    try {
      if (forceDownload == true && forceUpload == true) {
        throw ('[forceDownload] and [forceUpload] cannot be `true` at the same time.');
      }
      if (token.isEmpty) {
        throw ('[token] must be set.');
      }

      _lazyGDrive.token = token;

      syncing.value = true;

      // Remote file meta
      gd.File? gFile = await _lazyGDrive.getLatest(name: filename);
      int lastSaveMillisecondsRemote =
          (gFile?.modifiedTime ?? DateTime(0)).millisecondsSinceEpoch;

      // Local info
      int lastSaveMillisecondsLocal = localSaveTime.millisecondsSinceEpoch;

      // Sync logic
      if (gFile != null &&
          (forceDownload ||
              lastSaveMillisecondsRemote > lastSaveMillisecondsLocal)) {
        // remote file exist and is newer or forced -> download
        String content = await _lazyGDrive.download(gFile);
        if (setLocalContent == null) {
          throw ('setLocalContent callback not provided.');
        }
        setLocalContent!(content, gFile.modifiedTime);
      } else if (forceUpload ||
          lastSaveMillisecondsRemote < lastSaveMillisecondsLocal) {
        // no remote or local is newer or forced -> upload

        // Not using `update` nor `updateContent` as they cannot set modifiedTime
        _lazyGDrive.upload(
          name: filename,
          content: content,
          modifiedTime: localSaveTime,
        );
      } else {
        lazy.log('$debugPrefix:already up to date');
      }
      // clean up
      await _lazyGDrive.delCopies(name: filename);

      error.value = false;
      syncing.value = false;
      _lastSync = DateTime.now();
    } catch (e) {
      error.value = true;
      syncing.value = false;
      lazy.log('$debugPrefix:catch:$e');
    }
  }
}
