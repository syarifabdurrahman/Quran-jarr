package com.simpurrapps.quran_jarr.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import android.widget.RemoteViews
import com.simpurrapps.quran_jarr.R

/**
 * Simple Quran Widget Provider
 */
class QuranWidgetReceiver : AppWidgetProvider() {

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        Log.d("QuranWidget", "Widget enabled")
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        Log.d("QuranWidget", "Widget disabled")
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            try {
                val prefs = context.getSharedPreferences("QuranJarrWidget", Context.MODE_PRIVATE)

                // Get values with safe defaults and limit length
                val arabicText = prefs.getString("arabic_text", null)?.take(500) ?: "بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ"
                val translation = prefs.getString("translation", null)?.take(500) ?: "In the name of Allah, the Most Gracious, the Most Merciful"
                val surahName = prefs.getString("surah_name", null)?.take(100) ?: "Al-Fatiha"
                val surahNum = prefs.getInt("surah_number", 1)
                val ayahNum = prefs.getInt("ayah_number", 1)

                val views = RemoteViews(context.packageName, R.layout.quran_widget_layout)

                // Set text - colors are already defined in XML
                views.setTextViewText(R.id.widget_surah_name, "$surahName ($surahNum:$ayahNum)")
                views.setTextViewText(R.id.widget_arabic_text, arabicText)
                views.setTextViewText(R.id.widget_translation, translation)

                appWidgetManager.updateAppWidget(appWidgetId, views)
                Log.d("QuranWidget", "Widget $appWidgetId updated: $surahName ($surahNum:$ayahNum)")
            } catch (e: Exception) {
                Log.e("QuranWidget", "Error updating widget: ${e.message}", e)
                e.printStackTrace()
            }
        }
    }
}
