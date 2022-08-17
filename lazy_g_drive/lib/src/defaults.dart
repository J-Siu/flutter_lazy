import 'package:googleapis/drive/v3.dart' as gd;

const defaultGDriveDownloadOptions = gd.DownloadOptions.metadata;
const defaultGDriveFields =
    'nextPageToken, files(id, name, modifiedTime, parents)';
const defaultGDriveOrderByModifiedTime = 'modifiedTime';
const defaultGDriveParents = ['appDataFolder'];
const defaultGDriveSpace = 'appDataFolder';
const defaultGSignInScope = [gd.DriveApi.driveAppdataScope];
