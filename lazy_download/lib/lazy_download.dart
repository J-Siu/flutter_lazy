library lazy;

export 'src/download.dart' // Stub
    if (dart.library.html) 'src/download_web.dart' // dart:html
    show
        download;
