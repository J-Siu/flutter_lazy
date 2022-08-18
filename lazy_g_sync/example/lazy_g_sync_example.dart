import 'dart:async';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as gd;
import 'package:lazy_collection/lazy_collection.dart' as lazy;
import 'package:lazy_g_drive/lazy_g_drive.dart' as lazy;
import 'package:lazy_g_sync/lazy_g_sync.dart' as lazy;
import 'package:lazy_log/lazy_log.dart' as lazy;
import 'package:lazy_sign_in_google/lazy_sign_in_google.dart' as lazy;

// THIS IS NOT A COMPLETE APP, BUT SAMPLE STARTING POINT

// Your google sign in should have scope 'https://www.googleapis.com/auth/drive.appdata'
final globalLazySignIn = lazy.SignInGoogle(
  clientId: 'Google OAuth Client ID',
  scopes: [
    'email',
    'https://www.googleapis.com/auth/drive.appdata',
  ],
);
final lazyGSync = lazy.GSync(lazyGSignIn: globalLazySignIn);
final someLocalContent = SomeLocalContent();

void main() {
  // -- Register [SomeLocalContent] with [lazyGSync]

  // Tell GSync how to get content
  lazyGSync.getLocalContent = () => someLocalContent.toString();
  // Tell GSync how to get filename
  lazyGSync.getFilename = () => 'localContent.txt';
  // Tell GSync how to get local last save time
  lazyGSync.getLocalSaveTime = () => someLocalContent.lastSave;
  // Tell GSync who will send a save/sync trigger
  lazyGSync.localSaveNotifier = someLocalContent.saveNotifier;
  // Tell GSync how to set local content
  lazyGSync.setContent =
      (content, dateTime) => someLocalContent.content = content;
  runApp(const MyApp());
}

/// This can be local settings/preferences/content
class SomeLocalContent {
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
