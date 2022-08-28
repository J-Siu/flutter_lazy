import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as gd;
import 'package:lazy_g_drive/lazy_g_drive.dart' as lazy;
import 'package:lazy_log/lazy_log.dart' as lazy;
import 'package:lazy_sign_in/lazy_sign_in.dart' as lazy;

/// ### Lazy [GSync]
/// - Syncing single file with Google Drive `appData` space
/// - A bridge between [GDrive], [GSignIn] and local data/content
class GSync {
  // --- Internal

  final lazy.GDrive _lazyGDrive = lazy.GDrive();
  DateTime _lastSync = DateTime(0);
  Timer? _timer;
  bool _enableAutoSync = false;
  bool _enableSync = false;

  // --- Output

  /// `true` on [sync] error.
  /// `false` on [sync] success(no error).
  final ValueNotifier<bool> syncError = ValueNotifier<bool>(false);

  /// `true` when [sync] start
  /// `false` when [sync] stop
  final ValueNotifier<bool> syncing = ValueNotifier<bool>(false);

  // --- Input

  /// A [lazy.SignIn] instance, initialized with the desired [scope]
  /// - [GSignIn] default [scope] is [DriveApi.driveAppdataScope] | https://www.googleapis.com/auth/drive.appdata
  final lazy.SignIn lazyGSignIn;

  /// `Listenable` to trigger [sync] when [enableAutoSync] is `true`
  /// - Value/content of the `Listenable` is not being used.
  Listenable? localSaveNotifier;

  /// Should return last local save time
  DateTime Function()? getLocalSaveTime;

  /// Should return the content in [String] to be saved remotely
  String Function()? getLocalContent;

  /// Should return the remote filename in [String] to be used remotely
  String Function()? getFilename;

  /// Call when content is downloaded from remote
  /// - [String] : content of the download
  /// - [DateTime]? : remote last save time. Can be use to set local save time when applying content locally.
  void Function(String, DateTime?)? setContent;

  GSync({
    required this.lazyGSignIn,
    this.autoSyncIntervalMin = 10,
    this.getFilename,
    this.getLocalContent,
    this.getLocalSaveTime,
    this.localSaveNotifier,
    this.setContent,
  });

  /// Return last sync `DateTime`
  DateTime get lastSync => _lastSync;

  /// Return last save time of content/data saved locally (eg. in [shared_preferences])
  ///
  /// [getLocalSaveTime] must be set
  DateTime get localSaveTime {
    assert(
        getLocalSaveTime != null, '[getLocalSaveTime] function not provided.');
    return getLocalSaveTime!();
  }

  /// Return filename used when saving to Google Drive
  ///
  /// [getFilename] must be set
  String get filename {
    assert(getFilename != null, '[getFilename] function not provided.');
    return getFilename!();
  }

  /// Return content to be saved to Google Drive
  ///
  /// [getLocalContent] must be set
  String get content {
    assert(getLocalContent != null, '[getLocalContent] function not provided.');
    return getLocalContent!();
  }

  // --- Options

  /// Auto sync interval, time between [lastSync] till next sync
  int autoSyncIntervalMin = 10;

  /// [enableLocalSaveNotifier] control listening to [localSaveNotifier]
  /// - Start listening if `true`
  /// - Stop listening if `false`
  bool get enableLocalSaveNotifier => _enableSync;
  set enableLocalSaveNotifier(bool v) {
    assert(localSaveNotifier != null, '[localSaveNotifier] not provided.');
    if (_enableSync != v) {
      _enableSync = v;
      if (v) {
        // Enable Sites preference saving to trigger sync()
        localSaveNotifier!.addListener(() => sync());
        // Sync once when enable
        sync();
      } else {
        // Disable Sites preference saving to trigger sync()
        localSaveNotifier!.removeListener(() => sync());
      }
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
        lazy.log('$debugPrefix:gFiles.last:\n${lazy.jsonPretty(gFiles.last)}');
        lazy.log(
            '$debugPrefix:lastSaveTime:${gFiles.last.modifiedTime!.toUtc().toIso8601String()}');
      }
      return lastSaveTime;
    } catch (e) {
      throw ('$debugPrefix:catch:$e');
    }
  }

  /// [enableAutoSync] control period sync with interval = [autoSyncIntervalMin]
  /// - interval always count from [lastSync].
  bool get enableAutoSync => _enableAutoSync;
  set enableAutoSync(bool v) {
    if (_enableAutoSync != v) {
      _enableAutoSync = v;
      if (v) {
        // add 30min listener
        _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
          Duration sinceLastSync = DateTime.now().difference(_lastSync);
          if (sinceLastSync.inMinutes > autoSyncIntervalMin) {
            sync();
          }
        });
      } else {
        // remove listener
        _timer?.cancel();
      }
    }
  }

  /// Most of the time triggered by [localSaveNotifier].
  ///
  /// - Trigger sign-in if necessary. Handle by [GSignIn]
  /// - Initiate download from remote if [getLocalSaveTime] < google drive save time
  /// - Initiate upload to remote if [getLocalSaveTime] > google drive save time
  /// - Auto skip(no error) if [enableLocalSaveNotifier] is `false`, except when [forceDownload] or [forceUpload] is `true`
  ///
  /// - [syncing] : will be set to `true` at beginning and to `false` when done.
  /// - [syncError] : will be set to `true` on error. Reset(to `false`) on successful sync.
  ///
  /// - [forceDownload] : when set to `true`, will initiate download from remote regardless of save time on both sides
  /// - [forceUpload] : when set to `true`, will initiate upload to remote regardless of save time on both sides
  ///
  /// Assertion: [forceDownload] or [forceUpload] cannot be `true` in the same call.
  Future sync({
    bool forceDownload = false,
    bool forceUpload = false,
  }) async {
    String debugPrefix = '$runtimeType.sync()';
    assert(!(forceDownload == true && forceUpload == true),
        '[forceDownload] and [forceUpload] cannot be `true` at the same time.');
    if (!syncing.value) {
      lazy.log(debugPrefix);
      syncing.value = true;
      _lastSync = DateTime.now();
      try {
        // Get remote file list
        List<gd.File> gFiles = await remoteFiles();
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
        syncError.value = false;
        syncing.value = false;
      } catch (e) {
        syncError.value = true;
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
      // Login + setup GDrive
      _lazyGDrive.token = await lazyGSignIn.signInHandler();

      lazy.log('$debugPrefix:done sign-in');
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
    assert(setContent != null, '[setContent] function not provided.');
    String debugPrefix = '$runtimeType._download()';
    lazy.log(debugPrefix);

    try {
      String content = '';
      _lazyGDrive.token = await lazyGSignIn.signInHandler();
      var media = await _lazyGDrive.get(gFile.id!,
          downloadOptions: gd.DownloadOptions.fullMedia);
      if (media is gd.Media) {
        content = await utf8.decodeStream(media.stream);
        lazy.log('$debugPrefix:size:${content.length} byte');
      } else {
        throw ('$debugPrefix:File is not Google DriveApi Media.');
      }
      // Apply to sites
      setContent!(content, gFile.modifiedTime);
    } catch (e) {
      lazy.log('$debugPrefix:catch:$e');
    }
  }

  Future _upload() async {
    String debugPrefix = '$runtimeType._upload()';
    lazy.log(debugPrefix);

    try {
      // Login + setup GDrive
      _lazyGDrive.token = await lazyGSignIn.signInHandler();
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
      lazy.log(
          '$debugPrefix:result(should be empty):\n${lazy.jsonPretty(result)}');
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
