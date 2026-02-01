package com.wazza.app

import android.content.Context
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.wazza.app/share"
    private val EVENT_CHANNEL = "com.wazza.app/share_events"
    
    private var pendingShareUri: Uri? = null
    private var eventSink: EventChannel.EventSink? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialSharedFile" -> {
                    handleIntent(intent)
                    result.success(pendingShareUri?.toString())
                    pendingShareUri = null
                }
                "shareFile" -> {
                    val filePath = call.argument<String>("filePath")
                    val mimeType = call.argument<String>("mimeType")
                    val subject = call.argument<String>("subject")
                    
                    if (filePath != null) {
                        shareFile(filePath, mimeType, subject)
                        result.success(true)
                    } else {
                        result.error("INVALID_PATH", "File path is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
        
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }
                
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }
    
    private fun handleIntent(intent: Intent) {
        val action = intent.action
        val type = intent.type
        
        if (Intent.ACTION_SEND == action && type != null) {
            if (type == "application/octet-stream" || type.endsWith("gguf")) {
                val uri = intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
                if (uri != null) {
                    pendingShareUri = uri
                    eventSink?.success(uri.toString())
                }
            }
        } else if (Intent.ACTION_VIEW == action) {
            val uri = intent.data
            if (uri != null && uri.toString().endsWith(".gguf")) {
                pendingShareUri = uri
                eventSink?.success(uri.toString())
            }
        }
    }
    
    private fun shareFile(filePath: String, mimeType: String?, subject: String?) {
        val file = File(filePath)
        if (!file.exists()) return
        
        val uri = getUriForFile(this, file)
        val shareIntent = Intent().apply {
            action = Intent.ACTION_SEND
            putExtra(Intent.EXTRA_STREAM, uri)
            type = mimeType ?: "application/octet-stream"
            if (subject != null) {
                putExtra(Intent.EXTRA_SUBJECT, subject)
            }
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        
        startActivity(Intent.createChooser(shareIntent, "Share Model"))
    }
    
    private fun getUriForFile(context: Context, file: File): Uri {
        return androidx.core.content.FileProvider.getUriForFile(
            context,
            "${applicationContext.packageName}.fileprovider",
            file
        )
    }
}