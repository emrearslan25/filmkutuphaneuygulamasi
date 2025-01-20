import 'package:flutter/foundation.dart';

class LogService {
  static void debug(String message) {
    if (kDebugMode) {
      print('[DEBUG] $message');
    }
  }

  static void error(String message, [dynamic error]) {
    if (kDebugMode) {
      print('[ERROR] $message');
      if (error != null) {
        print(error);
      }
    }
  }
}
