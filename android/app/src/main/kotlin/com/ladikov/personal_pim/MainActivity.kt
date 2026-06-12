package com.ladikov.personal_pim

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ladikov.personal_pim/deeplink"
    private var initialUri: String? = null
    private var latestUri: String? = null
    private var initialUriConsumed = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Capture the initial intent URI
        initialUri = intent?.data?.toString()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialUri" -> {
                    if (!initialUriConsumed) {
                        initialUriConsumed = true
                        result.success(initialUri)
                    } else {
                        result.success(null)
                    }
                }
                "getLatestUri" -> {
                    val uri = latestUri
                    latestUri = null // consume it
                    result.success(uri)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // When the app is already running and receives a new intent (e.g., from widget click)
        latestUri = intent.data?.toString()
    }
}
