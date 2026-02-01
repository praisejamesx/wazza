package com.example.wazza

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "wazza.share"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSharedFile" -> {
                    handleSharedFile(result)
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun handleSharedFile(result: MethodChannel.Result) {
        try {
            val intent = this.intent
            val action = intent.action
            val type = intent.type
            
            if ((action == Intent.ACTION_SEND || action == Intent.ACTION_VIEW) && 
                type == "application/octet-stream") {
                
                var uri: Uri? = null
                
                if (action == Intent.ACTION_SEND) {
                    uri = intent.getParcelableExtra(Intent.EXTRA_STREAM)
                } else if (action == Intent.ACTION_VIEW) {
                    uri = intent.data
                }
                
                if (uri != null) {
                    // Get original filename
                    var fileName = "model_${System.currentTimeMillis()}.gguf"
                    contentResolver.query(uri, null, null, null, null)?.use { cursor ->
                        if (cursor.moveToFirst()) {
                            val nameIndex = cursor.getColumnIndex("_display_name")
                            if (nameIndex >= 0) {
                                fileName = cursor.getString(nameIndex) ?: fileName
                            }
                        }
                    }
                    
                    // Ensure it has .gguf extension
                    if (!fileName.endsWith(".gguf", ignoreCase = true)) {
                        fileName += ".gguf"
                    }
                    
                    // Save to app's internal storage
                    val modelsDir = File(filesDir, "shared_models")
                    if (!modelsDir.exists()) {
                        modelsDir.mkdirs()
                    }
                    
                    val outFile = File(modelsDir, fileName)
                    contentResolver.openInputStream(uri)?.use { input ->
                        FileOutputStream(outFile).use { output ->
                            input.copyTo(output)
                        }
                    }
                    
                    result.success(outFile.absolutePath)
                    return
                }
            }
            result.success(null)
        } catch (e: Exception) {
            result.error("SHARE_ERROR", "Failed to handle shared file: ${e.message}", null)
        }
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        this.intent = intent
    }
}