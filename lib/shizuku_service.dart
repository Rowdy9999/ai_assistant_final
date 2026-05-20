import 'package:flutter/services.dart';

class ShizukuService {
  static const platform = MethodChannel('com.ai.assistant/shizuku');
  static Future<bool> executeCommands(List<String> commands) async {
    try {
      for (var cmd in commands) {
        await platform.invokeMethod('runShellCommand', {'command': cmd});
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
