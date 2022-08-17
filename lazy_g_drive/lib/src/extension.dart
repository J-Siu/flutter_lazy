import 'package:googleapis/drive/v3.dart' as gd;

/// ### Lazy extension for [String]
extension GDriveStringExt on String {
  /// Create [Media] from [this] String
  gd.Media toMedia() =>
      gd.Media(Future.value(codeUnits).asStream().asBroadcastStream(), length);
}
