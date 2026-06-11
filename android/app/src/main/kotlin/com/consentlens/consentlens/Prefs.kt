package com.consentlens.consentlens

import android.content.Context
import android.content.SharedPreferences

/**
 * Shared state between the Kotlin side and Dart. Uses the same file as the
 * shared_preferences plugin ("FlutterSharedPreferences", keys prefixed with
 * "flutter.") so both worlds read and write the same values.
 */
object Prefs {
    private const val FILE = "FlutterSharedPreferences"
    private const val PREFIX = "flutter."

    const val KEY_USER_MODE = "user_mode"            // "adult" | "child"
    const val KEY_LAST_VERIFIED_AT = "last_verified_at" // millis

    fun get(context: Context): SharedPreferences =
        context.getSharedPreferences(FILE, Context.MODE_PRIVATE)

    fun userMode(context: Context): String =
        get(context).getString(PREFIX + KEY_USER_MODE, "adult") ?: "adult"

    fun setUserMode(context: Context, mode: String) {
        get(context).edit().putString(PREFIX + KEY_USER_MODE, mode).apply()
    }

    fun lastVerifiedAt(context: Context): Long =
        get(context).getLong(PREFIX + KEY_LAST_VERIFIED_AT, 0L)

    fun setLastVerifiedAt(context: Context, at: Long) {
        get(context).edit().putLong(PREFIX + KEY_LAST_VERIFIED_AT, at).apply()
    }
}
