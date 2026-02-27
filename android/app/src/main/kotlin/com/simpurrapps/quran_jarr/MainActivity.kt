package com.simpurrapps.quran_jarr

import android.content.Context
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.os.Bundle
import android.app.AlarmManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall

class MainActivity : FlutterActivity() {
    private lateinit var widgetChannel: MethodChannel
    private lateinit var alarmChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Widget channel
        widgetChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.simpurrapps.quran_jarr/widget")
        widgetChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> result.success(true)
                "updateWidget" -> updateWidget(call, result)
                else -> result.notImplemented()
            }
        }

        // Alarm permission channel
        alarmChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "quran_jarr/alarm")
        alarmChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkExactAlarmPermission" -> checkExactAlarmPermission(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun checkExactAlarmPermission(result: MethodChannel.Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                val canScheduleExact = alarmManager.canScheduleExactAlarms()
                result.success(canScheduleExact)
            } else {
                // On older Android versions, exact alarm permission is not needed
                result.success(true)
            }
        } catch (e: Exception) {
            result.error("PERMISSION_ERROR", e.message, null)
        }
    }

    private fun updateWidget(call: MethodCall, result: MethodChannel.Result) {
        try {
            val arabicText = call.argument<String>("arabicText") ?: ""
            val translation = call.argument<String>("translation") ?: ""
            val surahName = call.argument<String>("surahName") ?: ""
            val surahNumber = call.argument<Int>("surahNumber") ?: 1
            val ayahNumber = call.argument<Int>("ayahNumber") ?: 1

            val prefs = getSharedPreferences("QuranJarrWidget", Context.MODE_PRIVATE)
            prefs.edit().apply {
                putString("arabic_text", arabicText)
                putString("translation", translation)
                putString("surah_name", surahName)
                putInt("surah_number", surahNumber)
                putInt("ayah_number", ayahNumber)
            }.apply()

            // Trigger widget update
            val appWidgetManager = AppWidgetManager.getInstance(this)
            val widgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(this, com.simpurrapps.quran_jarr.widget.QuranWidgetReceiver::class.java)
            )

            // Only update if widget exists
            if (widgetIds.isNotEmpty()) {
                com.simpurrapps.quran_jarr.widget.QuranWidgetReceiver.updateAppWidget(
                    this,
                    appWidgetManager,
                    widgetIds[0]
                )
            }

            result.success(true)
        } catch (e: Exception) {
            result.error("UPDATE_ERROR", e.message, null)
        }
    }
}
