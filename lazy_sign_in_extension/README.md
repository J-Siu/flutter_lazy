Google sign-in library for extension using [lazy_sign_in](https://pub.dev/packages/lazy_sign_in) interface.

### Support Browser

`lazy_sign_in_extension` auto detect browser and use api accordingly.

| Browser | Identity API     |
| ------- | ---------------- |
| Chrome  | chrome.identity  |
| Firefox | browser.identity |
| Orion   | browser.identity |

### Install

```sh
flutter pub add lazy_sign_in_extension
```

### Usage

```dart
import 'package:lazy_sign_in_extension/lazy_sign_in_extension.dart' as lazy;
const String clientId = 'Google CHROME/WEB APP Client Id';
final lazy.SignInBase globalLazySignIn = lazy.SignInExt(clientId: clientId);
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

#### Web/App

Use [lazy_sign_in_google](https://pub.dev/packages/lazy_sign_in_google)

### Example

- Example folder
- Complete repo: https://github.com/J-Siu/flutter_lazy/example/lazy_sign_in_example/

You will have to supply your own `clientId` accordingly.
