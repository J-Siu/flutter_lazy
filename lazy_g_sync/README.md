GSync is created for syncing app data using Google Drive [appdata](https://developers.google.com/drive/api/guides/appdata) space.

Require Google authorization token with scope 'https://www.googleapis.com/auth/drive.appdata'.

[lazy.GDrive](https://pub.dev/packages/lazy_g_drive) for Google Drive access.

### Feature

Support
- manual sync
- auto(periodic) sync
- trigger sync via ValueNotifier<bool> notification
- force download
- force upload

### Install

```sh
flutter pub add lazy_g_sync
```

### Prerequisite

To access Google Drive appdata space
1. Application must have a Google Cloud [Client ID](https://cloud.google.com/endpoints/docs/frameworks/java/creating-client-ids)
2. Acquire Google authorization token using
    - [lazy.SignIn](https://pub.dev/packages/lazy_sign_in)
    - [GoogleSignIn](https://pub.dev/packages/google_sign_in)
    - other means to support Google Identity authentication and authorization

### Workflow

The workflow can be break down into setup, enable, sync, and error handling.

#### Setup

#### Enable

#### Sync

#### Error Handling