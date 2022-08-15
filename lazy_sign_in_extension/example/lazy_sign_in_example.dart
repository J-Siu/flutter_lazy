import 'package:flutter/material.dart';

// Uncomment following for Chrome/Firefox extension
import 'package:lazy_sign_in_extension/lazy_sign_in_extension.dart' as lazy;

final lazy.SignIn globalLazySignIn = lazy.SignInExt(clientId: clientId);

// // Uncomment following for Web/App
// import 'package:lazy_sign_in_google/lazy_sign_in_google.dart' as lazy;
// final lazy.SignIn globalLazySignIn = lazy.SignInGoogle(clientId: clientId);

/// - Chrome Extension
///   - use Google OAuth **Chrome Application** client id.
///   - update OAuth credential app id with extension id
/// - Firefox Extension
///   - use Google OAuth **Web Application** client id.
///   - update OAuth credential authorized redirect uri
///     this can be obtain by [redirectUrl]
/// - Web
///   - use Google OAuth **Web Application** client id.
///   - update OAuth credential authorized javaScript origins
/// - Standalone App
///   - use Google OAuth **Chrome Application** client id.
///   - update OAuth credential app id
const String clientId = 'Your Google OAuth client id';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  final String title = 'LazySignIn Example';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _photoUrl = '';
  @override
  void initState() {
    super.initState();
    globalLazySignIn.msg.addListener(() => _signInHandler());
  }

  @override
  void dispose() {
    globalLazySignIn.msg.removeListener(() => _signInHandler());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar() {
      if (_photoUrl.isNotEmpty) {
        return SizedBox(
          height: 60,
          width: 60,
          child: Image.network(_photoUrl),
        );
      } else {
        return const SizedBox();
      }
    }

    Widget buttonSignIn = TextButton(
      onPressed: () => globalLazySignIn.signInHandler(),
      child: const Text('Sign-In'),
    );
    Widget buttonSignOut = TextButton(
      onPressed: () => globalLazySignIn.signOutHandler(),
      child: const Text('Sign-Out'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buttonSignIn,
            buttonSignOut,
            avatar(),
          ],
        ),
      ),
    );
  }

  // this will trigger when token changes
  _signInHandler() {
    setState(() {
      _photoUrl = globalLazySignIn.photoUrl;
    });
  }
}
