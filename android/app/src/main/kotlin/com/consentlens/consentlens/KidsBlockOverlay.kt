package com.consentlens.consentlens

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView

/**
 * Full-screen friendly guard shown while Kids Mode is on and a non-approved
 * app comes to the foreground. Pure native view (no Flutter engine) so it
 * appears instantly. The big button bounces back to the ConsentLens play
 * screen; system Home/Back keys are NOT trapped (overlay is not focusable).
 */
object KidsBlockOverlay {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var view: View? = null

    fun show(context: Context) {
        mainHandler.post {
            val app = context.applicationContext
            if (view != null) return@post
            if (!Settings.canDrawOverlays(app)) return@post

            val lang = Prefs.language(app)
            val title = when (lang) {
                "hi" -> "🧸  यह ऐप बड़ों के लिए है"
                "kn" -> "🧸  ಈ ಆ್ಯಪ್ ದೊಡ್ಡವರಿಗೆ"
                else -> "🧸  This app is for grown-ups"
            }
            val sub = when (lang) {
                "hi" -> "इस्तेमाल से पहले बड़ों से पूछो"
                "kn" -> "ಬಳಸುವ ಮೊದಲು ದೊಡ್ಡವರನ್ನು ಕೇಳಿ"
                else -> "Ask a grown-up before using it"
            }
            val btnLabel = when (lang) {
                "hi" -> "वापस खेलें  🎈"
                "kn" -> "ಮತ್ತೆ ಆಡಿ  🎈"
                else -> "Back to play  🎈"
            }

            val root = LinearLayout(app).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER
                setBackgroundColor(Color.parseColor("#5B3FA8"))
                setPadding(64, 64, 64, 64)
            }
            root.addView(TextView(app).apply {
                text = title
                setTextColor(Color.WHITE)
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 24f)
                setTypeface(typeface, Typeface.BOLD)
                gravity = Gravity.CENTER
            })
            root.addView(TextView(app).apply {
                text = sub
                setTextColor(Color.parseColor("#CCFFFFFF"))
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
                gravity = Gravity.CENTER
                setPadding(0, 24, 0, 56)
            })
            root.addView(TextView(app).apply {
                text = btnLabel
                setTextColor(Color.parseColor("#5B3FA8"))
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f)
                setTypeface(typeface, Typeface.BOLD)
                gravity = Gravity.CENTER
                setBackgroundColor(Color.WHITE)
                setPadding(72, 36, 72, 36)
                setOnClickListener {
                    hide(app)
                    // SYSTEM_ALERT_WINDOW holders may start activities.
                    val intent = app.packageManager
                        .getLaunchIntentForPackage(app.packageName)
                        ?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        ?.putExtra("open", "kids")
                    if (intent != null) app.startActivity(intent)
                }
            })

            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                        or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                PixelFormat.OPAQUE
            )
            val wm = app.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            try {
                wm.addView(root, params)
                view = root
            } catch (_: Exception) {
            }
        }
    }

    fun hide(context: Context) {
        mainHandler.post {
            val v = view ?: return@post
            view = null
            val wm = context.applicationContext
                .getSystemService(Context.WINDOW_SERVICE) as WindowManager
            try {
                wm.removeView(v)
            } catch (_: Exception) {
            }
        }
    }
}
