package com.example.screen_capture_detector

import android.content.Context
import android.database.ContentObserver
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

class ScreenCaptureDetectorPlugin : FlutterPlugin {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    private var contentObserver: ContentObserver? = null
    private var lastPath: String? = null
    private var lastTimestamp: Long = 0
    
    // Track processed URIs to prevent duplicates
    private val processedUris = mutableSetOf<String>()
    private val handler = Handler(Looper.getMainLooper())
    private var cleanupRunnable: Runnable? = null

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        channel = MethodChannel(binding.binaryMessenger, "screen_capture_detector")
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startDetection" -> {
                    startDetection()
                    result.success(true)
                }
                "stopDetection" -> {
                    stopDetection()
                    result.success(true)
                }
                "getSdkVersion" -> result.success(Build.VERSION.SDK_INT)
                else -> result.notImplemented()
            }
        }
    }

    private fun startDetection() {
        if (contentObserver != null) return

        contentObserver = object : ContentObserver(Handler(Looper.getMainLooper())) {
            override fun onChange(selfChange: Boolean, uri: Uri?) {
                super.onChange(selfChange, uri)
                uri?.let { detectScreenshot(it) }
            }
        }

        context.contentResolver.registerContentObserver(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            true,
            contentObserver!!
        )
    }

    private fun detectScreenshot(uri: Uri) {
        // Samsung devices sometimes trigger onChange multiple times for the same screenshot
        // Check if we've already processed this URI recently
        val uriString = uri.toString()
        if (processedUris.contains(uriString)) {
            println("⚠️ URI already processed: $uriString")
            return
        }

        val projection = arrayOf(
            MediaStore.Images.Media._ID,
            MediaStore.Images.Media.DATA,
            MediaStore.Images.Media.DATE_ADDED,
            MediaStore.Images.Media.DISPLAY_NAME
        )

        try {
            context.contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val dataIndex = cursor.getColumnIndex(MediaStore.Images.Media.DATA)
                    val dateIndex = cursor.getColumnIndex(MediaStore.Images.Media.DATE_ADDED)
                    val nameIndex = cursor.getColumnIndex(MediaStore.Images.Media.DISPLAY_NAME)

                    if (dataIndex == -1 || dateIndex == -1 || nameIndex == -1) {
                        return
                    }

                    val path = cursor.getString(dataIndex) ?: return
                    val dateAdded = cursor.getLong(dateIndex)
                    val name = cursor.getString(nameIndex)?.lowercase() ?: ""

                    // IMPORTANT: Ignore Samsung's temporary .pending- files
                    if (name.startsWith(".pending-") || path.contains("/.pending-")) {
                        println("⚠️ Ignoring temporary pending file: $name")
                        return
                    }

                    val currentTime = System.currentTimeMillis() / 1000
                    val isRecent = Math.abs(currentTime - dateAdded) <= 10
                    val isScreenshot = path.lowercase().contains("screenshot") || 
                                     name.contains("screenshot")

                    if (isRecent && isScreenshot) {
                        // Check if this is the same screenshot (by path and timestamp)
                        val isSamePath = path == lastPath
                        val timeSinceLastNotification = System.currentTimeMillis() - lastTimestamp
                        val isDuplicate = isSamePath && timeSinceLastNotification < 2000 // 2 seconds

                        if (!isDuplicate) {
                            lastPath = path
                            lastTimestamp = System.currentTimeMillis()
                            
                            // Mark this URI as processed
                            processedUris.add(uriString)
                            
                            // Clean up old URIs after 15 seconds
                            scheduleUriCleanup(uriString)
                            
                            println("📸 Screenshot detected: $path")
                            handler.post {
                                channel.invokeMethod("onScreenshotTaken", path)
                            }
                        } else {
                            println("⚠️ Duplicate screenshot ignored: $path (${timeSinceLastNotification}ms since last)")
                        }
                    }
                }
            }
        } catch (e: Exception) {
            println("❌ Error detecting screenshot: ${e.message}")
            e.printStackTrace()
        }
    }

    private fun scheduleUriCleanup(uriString: String) {
        // Cancel previous cleanup if exists
        cleanupRunnable?.let { handler.removeCallbacks(it) }
        
        // Schedule new cleanup
        cleanupRunnable = Runnable {
            processedUris.remove(uriString)
            println("🧹 Cleaned up processed URI: $uriString")
        }
        
        handler.postDelayed(cleanupRunnable!!, 15000)
    }

    private fun stopDetection() {
        contentObserver?.let {
            context.contentResolver.unregisterContentObserver(it)
            contentObserver = null
        }
        
        // Clean up
        cleanupRunnable?.let { handler.removeCallbacks(it) }
        processedUris.clear()
        lastPath = null
        lastTimestamp = 0
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopDetection()
    }
}