[google_sign_in](https://pub.dev/packages/google_sing_in) wrapped in [lazy_sign_in](https://pub.dev/packages/lazy_sign_in) interface.

### Features

| Class               | File                     | Description                                                                           |
| ------------------- | ------------------------ | ------------------------------------------------------------------------------------- |
| [lazy.SignInGoogle] | lazy_sign_in_google.dart | Support Google sign-in in web or app. This is a wrapper of `package:google_sign_in` |

### Install

```sh
flutter pub add lazy_sign_in_google
```

### Usage

#### Web/App

For web page, supply Google OAuth **Web Application** client id.

For standalone app, supply Google OAuth **Chrome Application** client id.

```dart
import 'package:lazy_sign_in_google/lazy_sign_in_google.dart' as lazy;
const String clientId = 'Google CHROME/WEB APP Client Id';
final lazy.SignInBase globalLazySignIn = lazy.SignInGoogle(clientId: clientId);
```

#### One Interface/Api

```dart
Widget buttonSignIn = TextButton(
  onPressed: () => globalLazySignIn.signIn(),
  child: const Text('Sign-In'),
);

Widget buttonSignOut = TextButton(
  onPressed: () => globalLazySignIn.signOut(),
  child: const Text('Sign-Out'),
);
```

#### Chrome/Firefox Extension

[lazy_sign_in_extension](https://pub.dev/packages/lazy_sign_in_extension)

### Example

- Example folder
- Complete repo: https://github.com/J-Siu/flutter_lazy/example/lazy_sign_in_example/

You will have to supply your own `clientId` accordingly.
