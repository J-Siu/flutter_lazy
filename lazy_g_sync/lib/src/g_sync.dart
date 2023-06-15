import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as gd;
import 'package:lazy_extensions/lazy_extensions.dart';
import 'package:lazy_g_drive/lazy_g_drive.dart' as lazy;
import 'package:lazy_log/lazy_log.dart' as lazy;

/// ### Lazy [GSync]
/// - Syncing single file with Google Drive `appData` space
/// - A bridge between [GDrive], [GSignIn] and local data/content
class GSync {
  // --- Internal

  final lazy.GDrive _lazyGDrive = lazy.GDrive();
  DateTime _lastSync = DateTime(0);
  Listenable? _localSaveNotifier;
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

  String token = '';

  /// A callback, should return last local save time
  DateTime Function()? getLocalSaveTime;

  /// A callback, should return local content in [String] to be saved remotely
  String Function()? getLocalContent;

  /// A callback, should return a filename in [String] to be used remotely
  String Function()? getFilename;

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

  /// [enable]
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
  /// [lastSync] has no significant on sync logic.
  DateTime get lastSync => _lastSync;

  /// Return last save time of content/data saved locally (eg. in [shared_preferences])
  /// Result from [getLocalSaveTime]
  /// [getLocalSaveTime] must be set
  DateTime get localSaveTime {
    assert(
        getLocalSaveTime != null, '[getLocalSaveTime] function not provided.');
    return getLocalSaveTime!();
  }

  /// Return filename used when saving to Google Drive
  /// Result from [getFilename]
  /// [getFilename] must be set
  String get filename {
    assert(getFilename != null, '[getFilename] function not provided.');
    return getFilename!();
  }

  /// Return content to be saved to Google Drive
  /// Result from [getLocalContent]
  /// [getLocalContent] must be set
  String get content {
    assert(getLocalContent != null, '[getLocalContent] function not provided.');
    return getLocalContent!();
  }

  // --- Options

  /// Auto sync interval, time between [lastSync] till next sync
  int autoSyncIntervalMin = 10;

  /// [localSaveNotifier]
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

  /// Return modify time of the last entry from [gFiles]
  /// - If [gFiles] is empty, `DateTime(0)` is returned.
  Future<DateTime> remoteLastSaveTime(List<gd.File> gFiles) async {
    String debugPrefix = '$runtimeType.remoteLastSaveTime()';
    try {
      lazy.log('$debugPrefix:${gFiles.length}');
      DateTime lastSaveTime = DateTime(0);
      if (gFiles.isNotEmpty) {
        lastSaveTime = gFiles.last.modifiedTime ?? DateTime(0);
        lazy.log('$debugPrefix:gFiles.last:\n${gFiles.last.jsonPretty()}');
        lazy.log(
            '$debugPrefix:lastSaveTime:${gFiles.last.modifiedTime!.toUtc().toIso8601String()}');
      }
      return lastSaveTime;
    } catch (e) {
      throw ('$debugPrefix:catch:$e');
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

  /// Most of the time triggered by [localSaveNotifier].
  ///
  /// - Initiate download from remote if [getLocalSaveTime] < google drive save time
  /// - Initiate upload to remote if [getLocalSaveTime] > google drive save time
  /// - Auto skip(no error) if
  ///   - [enable] is `false`, except when [forceDownload] or [forceUpload] is `true`
  ///   - [error.value] is `true`, except [ignoreError] set to `true`
  ///
  /// - [syncing.value] : will be set to `true` at beginning and to `false` when done.
  /// - [error.value] : will be set to `true` on error. Reset(to `false`) on successful sync.
  ///
  /// - [forceDownload] : when set to `true`, will initiate download from remote regardless of save time on both sides
  /// - [forceUpload] : when set to `true`, will initiate upload to remote regardless of save time on both sides
  ///
  /// Assertion
  /// - [forceDownload] and [forceUpload] cannot be `true` at the same call.
  /// - [token] must be set (not empty).
  Future sync({
    bool forceDownload = false,
    bool forceUpload = false,
    bool ignoreError = false,
  }) async {
    String debugPrefix = '$runtimeType.sync()';
    if (enable && !syncing.value && (!error.value || ignoreError)) {
      lazy.log(debugPrefix);
      try {
        assert(!(forceDownload == true && forceUpload == true),
            '[forceDownload] and [forceUpload] cannot be `true` at the same time.');
        assert(token.isNotEmpty, '[token] must be set.');
        // Get remote file list
        List<gd.File> gFiles = await remoteFiles();

        syncing.value = true;

        int lastSaveMillisecondsGDrive =
            (await remoteLastSaveTime(gFiles)).millisecondsSinceEpoch;
        // Local info
        int lastSaveMillisecondsLocal = localSaveTime.millisecondsSinceEpoch;
        lazy.log(
            '$debugPrefix:lastSaveTimeLocal :${localSaveTime.toUtc().toIso8601String()}');
        // Sync logic
        if (gFiles.isNotEmpty &&
            (forceDownload ||
                lastSaveMillisecondsGDrive > lastSaveMillisecondsLocal)) {
          // remote is newer -> download
          _download(gFiles.last);
        } else if (gFiles.isEmpty ||
            forceUpload ||
            lastSaveMillisecondsGDrive < lastSaveMillisecondsLocal) {
          // no remote or local is newer -> upload
          _upload();
        } else {
          lazy.log('$debugPrefix:already up to date');
        }
        // clean up
        await _cleanUpOldFiles(gFiles);
        error.value = false;
        syncing.value = false;
        _lastSync = DateTime.now();
      } catch (e) {
        error.value = true;
        syncing.value = false;
        lazy.log('$debugPrefix:catch:$e');
      }
    } else {
      lazy.log('$debugPrefix:syncing in progress');
    }
  }

  /// Return remote file list of the given filename
  Future<List<gd.File>> remoteFiles() async {
    String debugPrefix = '$runtimeType.remoteFiles()';
    try {
      _lazyGDrive.token = token;
      // remote info
      String q = "name: '$filename'";
      var gFileList = await _lazyGDrive.list(
        fields: 'nextPageToken, files(id, name, modifiedTime, parents)',
        orderBy: 'modifiedTime',
        spaces: 'appDataFolder',
        q: q,
      );
      lazy.log('$debugPrefix:$gFileList');
      List<gd.File> gFiles = gFileList.files ?? [];
      lazy.log('$debugPrefix:${gFiles.length}');
      return gFiles;
    } catch (e) {
      throw ('$debugPrefix:catch:$e');
    }
  }

  /// _download()
  ///
  /// Download also apply data to [sites]
  Future _download(gd.File gFile) async {
    assert(setLocalContent != null, '[setContent] function not provided.');
    String debugPrefix = '$runtimeType._download()';
    lazy.log(debugPrefix);

    try {
      String content = '';
      _lazyGDrive.token = token;
      var media = await _lazyGDrive.get(gFile.id!,
          downloadOptions: gd.DownloadOptions.fullMedia);
      if (media is gd.Media) {
        content = await utf8.decodeStream(media.stream);
        lazy.log('$debugPrefix:size:${content.length} byte');
      } else {
        throw ('File is not Google DriveApi Media.');
      }
      // Apply to sites
      setLocalContent!(content, gFile.modifiedTime);
    } catch (e) {
      lazy.log('$debugPrefix:catch:$e');
    }
  }

  Future _upload() async {
    String debugPrefix = '$runtimeType._upload()';
    lazy.log(debugPrefix);

    try {
      // Login + setup GDrive
      _lazyGDrive.token = token;
      // File meta + content
      var file = lazy.gDriveFileMeta(
        name: filename,
        modifiedTime: localSaveTime,
        parents: ['appDataFolder'],
      );
      // [toMedia] use utf8 encoding
      var media = content.toMedia();
      lazy.log('$debugPrefix:size:${media.length}byte');
      // Upload
      var result = await _lazyGDrive.create(file: file, uploadMedia: media);
      lazy.log('$debugPrefix:result(should be empty):\n${result.jsonPretty()}');
    } catch (e) {
      lazy.log('$debugPrefix:catch:$e');
    }
  }

  Future _cleanUpOldFiles(List<gd.File> gFiles,
      {int keepNumberOfLatest = 5}) async {
    var debugPrefix = '$runtimeType._cleanUpOldFiles()';
    if (gFiles.length > keepNumberOfLatest) {
      for (var gFile in gFiles.sublist(0, gFiles.length - keepNumberOfLatest)) {
        if (gFile.id != null) {
          _lazyGDrive.del(gFile.id!);
          lazy.log('$debugPrefix: deleted $filename id: ${gFile.id}');
        }
      }
    }
  }
}
