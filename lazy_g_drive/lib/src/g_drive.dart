import 'dart:async';
import 'defaults.dart';
import 'package:googleapis/drive/v3.dart' as gd;
import 'package:lazy_extensions/lazy_extensions.dart' as lazy;
import 'package:lazy_log/lazy_log.dart' as lazy;
import 'package:lazy_http_client/lazy_http_client.dart' as lazy;

const _errorNotSignIn = "'token' cannot be null(Not sign-in).";

/// ### Lazy [GDrive]
/// - [token] is empty during instantiate. However it must be set before calling any calling any method [create], [get], [list], [searchLatest].
class GDrive {
  // --- internal
  String _token = '';
  final lazy.HttpClient _httpClient = lazy.HttpClient();
  gd.DriveApi? __driveApi;

  // --- option
  /// Print file list in log
  bool debugLogList = true;

  // --- Getter/Setter

  /// Google OAuth access token. Will throw if empty.
  String get token {
    if (_token.isEmpty) throw ('$runtimeType:$_errorNotSignIn');
    lazy.log('$runtimeType.token get:$_token');
    return _token;
  }

  set token(String v) {
    if (v.isEmpty) throw ('$runtimeType:$_errorNotSignIn');
    if (_token != v) {
      _token = v;
      var headers = lazy.Headers.gApis(_token);
      _httpClient.headers = headers;
      __driveApi = gd.DriveApi(_httpClient);
    }
  }

  gd.DriveApi get _driveApi {
    if (_token.isEmpty) throw ('$runtimeType:$_errorNotSignIn');
    return __driveApi as gd.DriveApi;
  }

// Methods

  /// [DriveApi.files.create] wrapper
  Future<gd.File> create({
    required gd.File file,
    required gd.Media uploadMedia,
  }) async {
    String debugPrefix = '$runtimeType.create()';
    try {
      lazy.log('$debugPrefix:\n${file.jsonPretty()}');
      return _driveApi.files.create(file, uploadMedia: uploadMedia);
    } catch (e) {
      throw ('$debugPrefix:$e');
    }
  }

  /// [DriveApi.files.list] wrapper
  Future<gd.FileList> list({
    String fields = defaultGDriveFields,
    String orderBy = defaultGDriveOrderByModifiedTime,
    String spaces = defaultGDriveSpace,
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

  /// [DriveApi.files.get] wrapper
  Future<Object> get(
    String fileId, {
    gd.DownloadOptions downloadOptions = defaultGDriveDownloadOptions,
  }) async {
    String debugPrefix = '$runtimeType.get()';
    try {
      return _driveApi.files.get(fileId, downloadOptions: downloadOptions);
    } catch (e) {
      throw ('$debugPrefix:$e');
    }
  }

  /// [DriveApi.files.del] wrapper
  Future del(String fileId) async {
    String debugPrefix = '$runtimeType.del()';
    try {
      return _driveApi.files.delete(fileId);
    } catch (e) {
      throw ('$debugPrefix:$e');
    }
  }

  /// Get the latest copy of a given file
  /// - Throw if error or not found
  Future<gd.File> searchLatest(String name) async {
    var debugPrefix = '$runtimeType.searchLatest()';
    // Get FileList containing name
    try {
      String q = "name: '$name'";
      List<gd.File> gFiles = (await list(q: q)).files ?? [];
      if (debugLogList) {
        lazy.log('$debugPrefix:gFiles:\n${gFiles.jsonPretty()}');
      }
      // Get file meta, which contain id
      if (gFiles.isEmpty) throw ('$name not found.');
      lazy.log('$debugPrefix:gFiles.last:\n${gFiles.last.jsonPretty()}');
      return gFiles.last;
    } catch (e) {
      throw ('$debugPrefix:$e');
    }
  }
}
