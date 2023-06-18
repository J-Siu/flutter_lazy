import 'package:googleapis/drive/v3.dart' as gd;

/// [defaultGDriveScope] = ```[gd.DriveApi.driveAppdataScope]```
const defaultGDriveScope = [gd.DriveApi.driveAppdataScope];

/// [defaultGDriveDownloadOptions] = [gd.DownloadOptions.metadata]
const defaultGDriveDownloadOptions = gd.DownloadOptions.metadata;

/// [defaultGDriveFields] =
///   'nextPageToken, files(id, name, modifiedTime, parents)'
const defaultGDriveFields =
    'nextPageToken, files(id, name, modifiedTime, parents)';

/// [defaultGDriveOrderBy] = 'modifiedTime'
const defaultGDriveOrderBy = 'modifiedTime';

/// [defaultGDriveParents] = ```['appDataFolder']```
const defaultGDriveParents = ['appDataFolder'];

/// [defaultGDriveSpace] = 'appDataFolder';
const defaultGDriveSpace = 'appDataFolder';
