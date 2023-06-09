import 'package:flutter/material.dart';

/// ### Lazy [IsSignIn]
/// - [status] ==
class IsSignedIn with ChangeNotifier {
  bool _status = false;
  IsSignedIn() {
    status = false;
  }

  bool get status => _status;
  set status(bool v) {
    _status = v;
    notifyListeners();
  }
}
