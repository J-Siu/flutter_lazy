import 'package:googleapis/drive/v3.dart' as gd;
import 'package:lazy_extensions/lazy_extensions.dart' as lazy;

/// ### Lazy extension for [String]
extension GDriveStringExt on String {
  /// Create [Media] from [this] String
  gd.Media toMedia() =>
      gd.Media(Future.value(toUtf8()).asStream().asBroadcastStream(), length);
}
