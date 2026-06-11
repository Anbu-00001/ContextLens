package com.consentlens.consentlens

import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.WindowManager
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterTextureView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * Hosts the ConsentLens popup: a second Flutter engine running the
 * `overlayMain` entrypoint, rendered into a TYPE_APPLICATION_OVERLAY window.
 * The popup UI itself is pure Flutter (same ConsentLens design system).
 */
object OverlayController {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var engine: FlutterEngine? = null
    private var channel: MethodChannel? = null
    private var view: FlutterView? = null
    private var pendingPayload: String? = null

    fun show(context: Context, payload: String) {
        mainHandler.post {
            val app = context.applicationContext
            pendingPayload = payload
            ensureEngine(app)
            channel?.invokeMethod("show", payload)
            attachView(app)
        }
    }

    fun hide(context: Context) {
        mainHandler.post { detachView(context.applicationContext) }
    }

    private fun ensureEngine(app: Context) {
        if (engine != null) return
        val loader = FlutterInjector.instance().flutterLoader()
        if (!loader.initialized()) {
            loader.startInitialization(app)
            loader.ensureInitializationComplete(app, null)
        }
        val eng = FlutterEngine(app) // auto-registers plugins (tts, prefs)
        eng.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(loader.findAppBundlePath(), "overlayMain")
        )
        val ch = MethodChannel(eng.dartExecutor.binaryMessenger, "consentlens/overlay")
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                "getPayload" -> result.success(pendingPayload)
                "close" -> {
                    detachView(app)
                    result.success(null)
                }
                "openAppDetails" -> {
                    val pkg = call.argument<String>("pkg")
                    if (pkg != null) {
                        val intent = Intent(
                            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                            Uri.parse("package:$pkg")
                        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        app.startActivity(intent)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        engine = eng
        channel = ch
    }

    private fun attachView(app: Context) {
        if (view != null) return
        val eng = engine ?: return
        if (!Settings.canDrawOverlays(app)) return

        val flutterView = FlutterView(app, FlutterTextureView(app))
        flutterView.attachToFlutterEngine(eng)
        eng.lifecycleChannel.appIsResumed()

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                    or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN
                    or WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
            PixelFormat.TRANSLUCENT
        )
        val wm = app.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        try {
            wm.addView(flutterView, params)
            view = flutterView
        } catch (_: Exception) {
            flutterView.detachFromFlutterEngine()
        }
    }

    private fun detachView(app: Context) {
        val v = view ?: return
        view = null
        val wm = app.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        try {
            wm.removeView(v)
        } catch (_: Exception) {
        }
        v.detachFromFlutterEngine()
        engine?.lifecycleChannel?.appIsPaused()
    }
}
