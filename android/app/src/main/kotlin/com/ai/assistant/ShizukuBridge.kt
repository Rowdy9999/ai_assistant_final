package com.ai.assistant

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import rikka.shizuku.Shizuku

class ShizukuBridge {
    fun setup(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.ai.assistant/shizuku")
            .setMethodCallHandler { call, result ->
                if (call.method == "runShellCommand") {
                    val command = call.argument<String>("command")
                    if (command != null) {
                        val success = executeCommand(command)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARG", "Command was null", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun executeCommand(command: String): Boolean {
        return try {
            Shizuku.newProcess(arrayOf("sh", "-c", command), null, null).waitFor() == 0
        } catch (e: Exception) {
            false
        }
    }
}
