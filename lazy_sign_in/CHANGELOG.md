## 2.1.0
- Added ValueNotifier
  - ValueNotifier<bool> isSignedIn
  - ValueNotifier<String> token
- Removed
  - [SignInMsg]

## 2.0.0
- update dependency
- [SignInMsg] replaced by [IsSignIn] with ChangeNotifier
- [SignIn]
  - added ChangeNotifier support
  - added bool [isAuthorized]
  - added bool [isSignedIn]
  - added String [displayName]
  - added get [token]
  - [signInHandler] changed to [signIn]
  - [signOutHandler] changed to [signOut]
## 1.1.1
- update dependency
## 1.1.0
- Fix log
## 1.0.3
- update dependency
## 1.0.2
- use lazy_log 1.0.2
## 1.0.1
- Update example
- Add [SignInDummy]
## 1.0.0
- Initial version.