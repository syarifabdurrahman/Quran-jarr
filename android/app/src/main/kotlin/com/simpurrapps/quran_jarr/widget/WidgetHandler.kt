package com.simpurrapps.quran_jarr.widget

import android.content.Context
import android.content.SharedPreferences
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

/**
 * Widget Handler - Handles platform channel communication from Flutter
 */
class WidgetHandler : FlutterPlugin {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    companion object {
        const val CHANNEL = "com.simpurrapps.quran_jarr/widget"
        const val PREFS_NAME = "QuranJarrWidget"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    result.success(true)
                }
                "updateWidget" -> {
                    updateWidget(call, result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun updateWidget(call: MethodCall, result: MethodChannel.Result) {
        try {
            val arabicText = call.argument<String>("arabicText") ?: ""
            val translation = call.argument<String>("translation") ?: ""
            val surahName = call.argument<String>("surahName") ?: ""
            val surahNumber = call.argument<Int>("surahNumber") ?: 1
            val ayahNumber = call.argument<Int>("ayahNumber") ?: 1

            // Save to preferences for widget to read
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().apply {
                putString("arabic_text", arabicText)
                putString("translation", translation)
                putString("surah_name", surahName)
                putInt("surah_number", surahNumber)
                putInt("ayah_number", ayahNumber)
            }.apply()

            // Trigger widget update
            QuranWidget().updateAll(context)

            result.success(true)
        } catch (e: Exception) {
            result.error("UPDATE_ERROR", e.message, null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
