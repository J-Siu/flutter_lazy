import 'package:flutter/material.dart';
import 'package:lazy_g_sync/lazy_g_sync.dart' as lazy;
import 'package:lazy_sign_in_google/lazy_sign_in_google.dart' as lazy;

// THIS IS ***NOT A COMPLETE APP***, BUT SAMPLE STARTING POINT

// Your google sign in should have scope 'https://www.googleapis.com/auth/drive.appdata'
final globalLazySignIn = lazy.SignInGoogle(
  clientId: 'Google OAuth Client ID',
  scopes: [
    'email',
    'https://www.googleapis.com/auth/drive.appdata',
  ],
);
final lazyGSync = lazy.GSync();
final dummyContent = DummyContent();

void main() {
  // -- Register [SomeLocalContent] with [lazyGSync]

  // Tell GSync how to get content
  lazyGSync.getLocalContent = () => dummyContent.toString();
  // Tell GSync how to get filename
  lazyGSync.getFilename = () => 'localContent.txt';
  // Tell GSync how to get local last save time
  lazyGSync.getLocalSaveTime = () => dummyContent.lastSave;
  // Tell GSync who will send a save/sync trigger
  lazyGSync.localSaveNotifier = dummyContent.saveNotifier;
  // Tell GSync how to set local content
  lazyGSync.setLocalContent =
      (content, dateTime) => dummyContent.content = content;
  runApp(const MyApp());
}

/// This can be local settings/preferences/content
class DummyContent {
  String content = '';
  DateTime lastSave = DateTime(0);

  @override
  String toString() {
    return content;
  }

  ValueNotifier<bool> saveNotifier = ValueNotifier(true);

  /// [save] will also trigger the notifier
  save(String v) {
    content = v;
    saveNotifier.value = !saveNotifier.value;
  }
}
