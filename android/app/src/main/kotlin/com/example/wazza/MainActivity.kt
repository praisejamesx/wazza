package com.example.wazza

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "wazza.share"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getSharedFile") {
                val intent = this.intent
                if (Intent.ACTION_SEND == intent.action && intent.type?.startsWith("application/") == true) {
                    val uri = intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
                    if (uri != null) {
                        try {
                            var fileName = "model.gguf"
                            contentResolver.query(uri, null, null, null, null)?.use { cursor ->
                                if (cursor.moveToFirst()) {
                                    val nameIndex = cursor.getColumnIndex("_display_name")
                                    if (nameIndex >= 0) {
                                        fileName = cursor.getString(nameIndex)
                                    }
                                }
                            }
                            if (!fileName.endsWith(".gguf")) {
                                fileName += ".gguf"
                            }
                            val outFile = File(filesDir, fileName)
                            contentResolver.openInputStream(uri)?.use { input ->
                                FileOutputStream(outFile).use { output ->
                                    input.copyTo(output)
                                }
                            }
                            result.success(outFile.absolutePath)
                            return@setMethodCallHandler
                        } catch (e: Exception) {
                            // ignore
                        }
                    }
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        this.intent = intent
    }
}