import 'dart:async';
import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as gd;
import 'package:lazy_extensions/lazy_extensions.dart' as lazy;
import 'package:lazy_log/lazy_log.dart' as lazy;
import 'package:lazy_http_client/lazy_http_client.dart' as lazy;
import '../lazy_g_drive.dart' as lazy;

const _errorTokenIsEmpty = "token is empty.";

/// [token] is empty during instantiate. However it must be set before calling any calling any method.
class GDrive {
  // --- internal
  String _token = '';
  final lazy.HttpClient _httpClient = lazy.HttpClient();
  gd.DriveApi? __driveApi;

  // --- option
  /// Print file list in log
  bool debugLogList = true;

  // --- Getter/Setter

  /// Google OAuth2 token
  String get token => _token;
  set token(String v) {
    if (v.isEmpty) throw (_errorTokenIsEmpty);
    if (_token != v) {
      _token = v;
      var headers = lazy.Headers.gApis(_token);
      _httpClient.headers = headers;
      __driveApi = gd.DriveApi(_httpClient);
    }
  }

  gd.DriveApi get _driveApi {
    if (_token.isEmpty) throw (_errorTokenIsEmpty);
    return __driveApi as gd.DriveApi;
  }

// Methods

  /// `DriveApi.files.create` wrapper that create file with media(file content)
  Future<gd.File> create({
    required gd.File file,
    required gd.Media uploadMedia,
  }) async {
    String debugPrefix = '$runtimeType.create()';
    try {
      lazy.log('$debugPrefix:\n${file.jsonPretty()}');
      return _driveApi.files.create(
        file,
        uploadMedia: uploadMedia,
      );
    } catch (e) {
      throw ('$debugPrefix:$e');
    }
  }

  /// `DriveApi.files.update` wrapper that only update media(file content)
  Future<gd.File> update({
    required gd.File file,
    required gd.Media uploadMedia,
  }) async {
    String debugPrefix = '$runtimeType.create()';
    try {
      lazy.log('$debugPrefix:\n${file.jsonPretty()}');
      if (file.id == null) throw ('file object has not id(null)!');
      return _driveApi.files.update(
        file,
        file.id!,
        uploadMedia: uploadMedia,
      );
    } catch (e) {
      throw ('$debugPrefix:$e');
    }
  }

  /// `DriveApi.files.list` wrapper
  Future<gd.FileList> list({
    String fields = lazy.defaultGDriveFields,
    String orderBy = lazy.defaultGDriveOrderBy,
    String spaces = lazy.defaultGDriveSpace,
    String? q,
  }) async {
    String debugPrefix = '$runtimeType.list()';
    try {
      return _driveApi.files.list(
        $fields: fields,
        orderBy: orderBy,
        q: q,
        spaces: spaces,
      );
    } catch (e) {
      throw ('$debugPrefix:$e');
    }
  }

  /// `DriveApi.files.get` wrapper
  Future<Object> get(
    String fileId, {
    gd.DownloadOptions downloadOptions = lazy.defaultGDriveDownloadOptions,
  }) async {
    String debugPrefix = '$runtimeType.get()';
    try {
      return _driveApi.files.get(
        fileId,
        downloadOptions: downloadOptions,
      );
    } catch (e) {
      throw ('$debugPrefix:$e');
    }
  }

  /// `DriveApi.files.del` wrapper
  Future del(String fileId) async {
    String debugPrefix = '$runtimeType.del()';
    try {
      return _driveApi.files.delete(fileId);
    } catch (e) {
      throw ('$debugPrefix:$e');
    }
  }

  // --- NON-Wrapper methods ---

  /// Return content of [gFile] in String
  Future<String> download(gd.File gFile) async {
    String debugPrefix = '$runtimeType.download()';
    lazy.log(debugPrefix);

    var media = await get(
      gFile.id!,
      downloadOptions: gd.DownloadOptions.fullMedia,
    );
    if (media is gd.Media) {
      String content = await utf8.decodeStream(media.stream);
      lazy.log('$debugPrefix:size:${content.length} byte');
      return content;
    } else {
      throw ('$debugPrefix:File is not Google DriveApi Media.');
    }
  }

  /// Create remote file [name] with [content]
  ///
  /// - [name] is filename
  /// - [content] is String
  /// - [parents] default 'appDataFolder'
  /// - [modifiedTime] create remote file with supplied time if not null
  Future upload({
    required String name,
    required String content,
    DateTime? modifiedTime,
    List<String> parents = lazy.defaultGDriveParents,
  }) async {
    String debugPrefix = '$runtimeType.upload()';
    lazy.log(debugPrefix);

    try {
      var file = lazy.gDriveFileMeta(
        name: name,
        modifiedTime: modifiedTime,
        parents: parents,
      );
      // [toMedia] use utf8 encoding
      var media = content.toMedia();
      lazy.log('$debugPrefix:size:${media.length}byte');
      // Upload/Create remote file
      var result = await create(file: file, uploadMedia: media);
      lazy.log('$debugPrefix:result(should be empty):\n${result.jsonPretty()}');
    } catch (e) {
      lazy.log('$debugPrefix:catch:$e');
    }
  }

  /// `DriveApi.files.update` wrapper that take String content and update file media(file content)
  Future updateContent({
    required gd.File file,
    required String content,
  }) async {
    String debugPrefix = '$runtimeType.updateContent()';
    lazy.log(debugPrefix);
    try {
      var result = await update(file: file, uploadMedia: content.toMedia());
      lazy.log('$debugPrefix:result:\n${result.jsonPretty()}');
    } catch (e) {
      lazy.log('$debugPrefix:catch:$e');
    }
  }

  /// - [name] is filename
  /// - [orderBy] result sort order, default sort by modified time
  /// - [spaces] Google Drive Space. default to 'appDataFolder'
  ///
  /// - Return remote file meta list
  /// - Return empty list if file not found.
  Future<List<gd.File>> listFiles({
    required String name,
    String orderBy = lazy.defaultGDriveOrderBy,
    String spaces = lazy.defaultGDriveSpace,
  }) async {
    String debugPrefix = '$runtimeType.listFiles()';
    try {
      // remote info
      String q = "name: '$name'";
      var gFileList = await list(
        fields: lazy.defaultGDriveFields,
        orderBy: orderBy,
        spaces: spaces,
        q: q,
      );
      lazy.log('$debugPrefix:${gFileList.jsonPretty()}');
      List<gd.File>? gFiles = gFileList.files ?? [];
      lazy.log('$debugPrefix:${gFiles.length}');
      return gFiles;
    } catch (e) {
      throw ('$debugPrefix:catch:$e');
    }
  }

  /// - [name] is filename
  /// - [spaces] Google Drive Space. default to 'appDataFolder'
  ///
  /// - Return meta of latest version of remote file with [name] in [spaces]
  /// - Return null if file not found.
  Future<gd.File?> getLatest({
    required String name,
    String spaces = lazy.defaultGDriveSpace,
  }) async {
    // Future<gd.File> searchLatest(String name) async {
    var debugPrefix = '$runtimeType.getLatest()';
    // Get FileList containing name
    try {
      List<gd.File> gFiles = await listFiles(
        name: name,
        spaces: spaces,
      );
      gd.File? gFile;
      if (gFiles.isNotEmpty) {
        gFile = gFiles.last;
        lazy.log('$debugPrefix:gFiles.last:\n${gFile.jsonPretty()}');
      }
      return gFile;
    } catch (e) {
      throw ('$debugPrefix:$e');
    }
  }

  /// Delete old copies of file with [name] in [spaces] and keep number of latest copy.
  ///
  /// - [name] is filename
  /// - [spaces] Google Drive Space. default to 'appDataFolder'
  /// - [keepNumberOfLatest] copy to be kept
  Future delCopies({
    required String name,
    String spaces = lazy.defaultGDriveSpace,
    int keepNumberOfLatest = 5,
  }) async {
    var debugPrefix = '$runtimeType.cleanUpOldFiles()';
    List<gd.File> gFiles = await listFiles(
      name: name,
      spaces: spaces,
    );
    if (gFiles.length > keepNumberOfLatest) {
      for (var gFile in gFiles.sublist(0, gFiles.length - keepNumberOfLatest)) {
        if (gFile.id != null) {
          lazy.log('$debugPrefix: deleted ${gFile.name} id: ${gFile.id}');
          del(gFile.id!);
        }
      }
    }
  }
}
