import 'defaults.dart';
import 'package:googleapis/drive/v3.dart' as gd;

gd.File gDriveFileMeta({
  DateTime? modifiedTime,
  List<String> parents = defaultGDriveParents,
  required String name,
}) {
  // File Metadata
  gd.File gdFile = gd.File();
  gdFile
    ..name = name
    ..parents = parents
    ..modifiedTime = modifiedTime ?? DateTime.now().toUtc();
  return gdFile;
}
